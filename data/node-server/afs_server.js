require("./runtime-version.cjs").assertSupportedRuntime();

if (process.argv.includes("--runtime-version")) {
    console.log(process.versions.node);
    process.exit(0);
}

const express = require("express");
const fs = require("fs");
const path = require("path");
const { DiscordIPC } = require("discord-ipc");

const CLIENT_ID = "1515967052353900544";
const DEFAULT_LARGE_IMAGE_TOOLTIP_TEXT = "AnyFunShare vx.x.x";
const configPath = path.join(__dirname, "..", "config.json");
const config = JSON.parse(fs.readFileSync(configPath, "utf8"));
const port = config.ServerSettings.Port;
const listenHost = "0.0.0.0";
const DISCORD_RPC_TIMEOUT_MS = 4500;
let discordReady = false;
let rpcOperationQueue = Promise.resolve();
let latestActivityState = {
    connected: false,
    activity: null,
    updatedAt: Date.now(),
    sourceIp: null
};

const app = express();
app.use(express.json());

const client = new DiscordIPC({
    clientId: CLIENT_ID,
    debug: true
});

function withTimeout(promise, timeoutMs, label) {
    return new Promise((resolve, reject) => {
        const timerId = setTimeout(() => {
            const timeoutError = new Error(`${label} timed out after ${timeoutMs}ms`);
            timeoutError.code = "ETIMEDOUT";
            reject(timeoutError);
        }, timeoutMs);

        Promise.resolve(promise)
            .then((value) => {
                clearTimeout(timerId);
                resolve(value);
            })
            .catch((error) => {
                clearTimeout(timerId);
                reject(error);
            });
    });
}

function waitMillis(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
}

function queueRpcOperation(label, operation) {
    const queued = rpcOperationQueue.then(async () => {
        return await withTimeout(operation(), DISCORD_RPC_TIMEOUT_MS, label);
    });

    // 次の処理が止まらないよう、キューは常に解放する
    rpcOperationQueue = queued.catch(() => undefined);
    return queued;
}

async function tryRecoverDiscord(reasonLabel) {
    console.warn(`Attempting Discord IPC recovery: ${reasonLabel}`);
    discordReady = false;

    try {
        await startDiscord();
        if (!discordReady) {
            await waitMillis(250);
            await startDiscord();
        }
    } catch (error) {
        console.error("Discord IPC recovery failed", error);
    }
}

function cleanActivityValue(val) {
    if (val === null || val === undefined || typeof val !== "string") {
        return undefined;
    }

    const trimmed = val.trim();
    if (trimmed.length <= 1) {
        return undefined;
    }

    return trimmed;
}

function cleanActivityName(val) {
    if (val === null || val === undefined) {
        return "AnyFunShare";
    }

    const str = String(val).trim();
    if (str.length === 0) {
        return "AnyFunShare";
    }

    // Discord RPCの制限回避: 過度に長いnameは切り詰める
    return str.substring(0, 128);
}

function cleanLargeImageKey(val) {
    if (val === null || val === undefined || typeof val !== "string") {
        return undefined;
    }

    const trimmed = val.trim();
    if (trimmed.length === 0) {
        return undefined;
    }

    return trimmed.substring(0, 128);
}

function normalizeActivityType(value) {
    const parsed = Number(value);
    if (!Number.isFinite(parsed)) {
        return 0;
    }

    const intType = Math.floor(parsed);
    if (intType < 0 || intType > 5) {
        return 0;
    }

    return intType;
}

function normalizeTimestamp(value) {
    if (value === null || value === undefined) {
        return undefined;
    }

    if (value instanceof Date) {
        return Math.floor(value.getTime() / 1000);
    }

    if (typeof value === "number" && Number.isFinite(value)) {
        // ミリ秒/秒の両入力を許容
        const millis = value > 9999999999 ? value : value * 1000;
        return Math.floor(millis / 1000);
    }

    if (typeof value === "string") {
        const parsed = Number(value);
        if (Number.isFinite(parsed)) {
            const millis = parsed > 9999999999 ? parsed : parsed * 1000;
            return Math.floor(millis / 1000);
        }
    }

    return undefined;
}

function resolveLargeImageTooltipText(req) {
    const rawVersion = req?.get("X-AnyFunShare-Version");
    if (!rawVersion || typeof rawVersion !== "string") {
        return DEFAULT_LARGE_IMAGE_TOOLTIP_TEXT;
    }

    const version = rawVersion.trim();
    if (version.length === 0) {
        return DEFAULT_LARGE_IMAGE_TOOLTIP_TEXT;
    }

    return `AnyFunShare v${version}`;
}

async function startDiscord() {
    if (discordReady) {
        return;
    }

    try {
        await client.connect();
        await client.handshake();
        discordReady = true;
        console.log("Discord ready");
    } catch (err) {
        console.error("Discord IPC is not ready", err);
    }
}

app.post("/activity", async (req, res) => {
    if (!discordReady) {
        res.status(503).json({
            success: false,
            error: "Discord IPC is not ready"
        });
        return;
    }

    try {
        const activityName = cleanActivityName(req.body.name);
        const details = cleanActivityValue(req.body.details);
        const state = cleanActivityValue(req.body.state);
        const largeImageKey = cleanLargeImageKey(req.body.assets?.large_image);
        const largeImageTooltipText = resolveLargeImageTooltipText(req);
        const activityType = normalizeActivityType(req.body.type);
        const startTimestamp = normalizeTimestamp(req.body.timestamps?.start);

        const activity = {
            name: activityName,
            details: details,
            state: state,
            type: activityType
        };

        if (largeImageKey) {
            activity.assets = {
                large_image: largeImageKey,
                large_text: largeImageTooltipText
            };
        }

        if (startTimestamp) {
            activity.timestamps = {
                start: startTimestamp
            };
        }

        try {
            await queueRpcOperation("setActivity", () => client.setActivity(activity));
        } catch (setErr) {
            // 詳細要素が原因で失敗する場合に備え、最小payloadで再試行する
            const fallbackActivity = {
                name: activityName,
                type: activityType
            };
            console.warn("setActivity failed. Trying fallback payload:", setErr?.message || setErr);

            try {
                await queueRpcOperation("setActivity(fallback)", () => client.setActivity(fallbackActivity));
            } catch (fallbackErr) {
                await tryRecoverDiscord("setActivity timeout/failure");
                await queueRpcOperation("setActivity(fallback-retry)", () => client.setActivity(fallbackActivity));
                console.warn("setActivity fallback retry used:", fallbackErr?.message || fallbackErr);
            }
        }

        latestActivityState = {
            connected: true,
            activity: {
                name: activity.name,
                details: activity.details,
                state: activity.state,
                type: activity.type,
                assets: {
                    large_image: activity.assets?.large_image,
                    large_text: activity.assets?.large_text
                },
                timestamps: activity.timestamps?.start
                    ? { start: activity.timestamps.start }
                    : undefined
            },
            updatedAt: Date.now(),
            sourceIp: req.ip
        };

        console.log(activity);

        res.json({
            success: true
        });
    } catch (err) {
        console.error(err);

        res.status(500).json({
            success: false,
            error: err.message
        });
    }
});

app.post("/activity/clear", async (req, res) => {
    if (!discordReady) {
        res.status(503).json({
            success: false,
            error: "Discord IPC is not ready"
        });
        return;
    }

    try {
        await queueRpcOperation("clearActivity", () => client.clearActivity());

        latestActivityState = {
            connected: false,
            activity: null,
            updatedAt: Date.now(),
            sourceIp: req.ip
        };

        console.log("Activity cleared");

        res.json({
            success: true
        });
    } catch (err) {
        console.error(err);

        try {
            await tryRecoverDiscord("clearActivity timeout/failure");
            await queueRpcOperation("clearActivity(retry)", () => client.clearActivity());

            latestActivityState = {
                connected: false,
                activity: null,
                updatedAt: Date.now(),
                sourceIp: req.ip
            };

            res.json({
                success: true,
                warning: "clearActivity recovered by retry"
            });
            return;
        } catch (retryErr) {
            console.error("clearActivity retry failed", retryErr);
        }

        res.status(500).json({
            success: false,
            error: err.message
        });
    }
});

app.get("/health", (req, res) => {
    res.json({
        success: true,
        discordReady,
        port,
        host: listenHost,
        updatedAt: Date.now()
    });
});

app.get("/activity/state", (req, res) => {
    res.json({
        success: true,
        discordReady,
        connected: latestActivityState.connected,
        activity: latestActivityState.activity,
        updatedAt: latestActivityState.updatedAt,
        sourceIp: latestActivityState.sourceIp
    });
});

app.listen(port, listenHost, () => {
    console.log(`Listening on ${listenHost}:${port}`);
});

startDiscord();
