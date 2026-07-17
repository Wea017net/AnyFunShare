const express = require("express");
const fs = require("fs");
const path = require("path");
const { DiscordIPC } = require("discord-ipc");

const CLIENT_ID = "1515967052353900544";
const configPath = path.join(__dirname, "..", "data", "config.json");
const config = JSON.parse(fs.readFileSync(configPath, "utf8"));
const port = config.ServerSettings.Port;
let discordReady = false;

const app = express();
app.use(express.json());

const client = new DiscordIPC({
    clientId: CLIENT_ID,
    debug: true
});

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

function normalizeTimestamp(value) {
    if (value === null || value === undefined) {
        return undefined;
    }

    if (value instanceof Date) {
        return value;
    }

    if (typeof value === "number" && Number.isFinite(value)) {
        return new Date(value);
    }

    if (typeof value === "string") {
        const parsed = Number(value);
        if (Number.isFinite(parsed)) {
            return new Date(parsed);
        }
    }

    return undefined;
}

async function startDiscord() {
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
        const details = cleanActivityValue(req.body.details);
        const state = cleanActivityValue(req.body.state);
        const startTimestamp = normalizeTimestamp(req.body.timestamps?.start);

        const activity = {
            name: req.body.name,
            details: details,
            state: state,
            type: req.body.type,
            assets: {
                large_image: req.body.assets?.large_image
            }
        };

        if (startTimestamp) {
            activity.timestamps = {
                start: startTimestamp
            };
        }

        await client.setActivity(activity);

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
        await client.clearActivity();

        console.log("Activity cleared");

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

app.listen(port, () => {
    console.log(`Listening on :${port}`);
});

startDiscord();