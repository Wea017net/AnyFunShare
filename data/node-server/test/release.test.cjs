const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const net = require("node:net");
const { spawn, execFileSync } = require("node:child_process");
const { setTimeout: delay } = require("node:timers/promises");
const { assertSupportedRuntime } = require("../runtime-version.cjs");

test("packaged server uses a patched runtime and serves HTTP without external dependencies", {
    skip: process.platform !== "win32",
    timeout: 20000
}, async () => {
    const directory = fs.mkdtempSync(path.join(os.tmpdir(), "anyfunshare-release-"));
    const serverDirectory = path.join(directory, "node-server");
    fs.mkdirSync(serverDirectory);
    const executable = path.join(serverDirectory, "afs_server.exe");
    fs.copyFileSync(path.join(__dirname, "..", "afs_server.exe"), executable);
    let child;
    let output = "";
    try {
        const version = execFileSync(executable, ["--runtime-version"], { encoding: "utf8", timeout: 5000 }).trim();
        assertSupportedRuntime(version);
        const listener = net.createServer();
        await new Promise((resolve, reject) => {
            listener.once("error", reject);
            listener.listen(0, "127.0.0.1", resolve);
        });
        const port = listener.address().port;
        await new Promise((resolve) => listener.close(resolve));
        fs.writeFileSync(path.join(directory, "config.json"), JSON.stringify({ ServerSettings: { Port: port } }));
        child = spawn(executable, [], { cwd: serverDirectory, windowsHide: true, env: { ...process.env, NODE_OPTIONS: "" } });
        let spawnError;
        child.once("error", (error) => { spawnError = error; });
        child.stdout.on("data", (chunk) => { output += chunk; });
        child.stderr.on("data", (chunk) => { output += chunk; });
        const baseUrl = `http://127.0.0.1:${port}`;
        let health;
        for (let attempt = 0; attempt < 60; attempt++) {
            if (spawnError) throw spawnError;
            if (child.exitCode !== null) throw new Error(`Server exited: ${output}`);
            try {
                const response = await fetch(`${baseUrl}/health`, { signal: AbortSignal.timeout(500) });
                health = await response.json();
                break;
            } catch {
                await delay(100);
            }
        }
        assert.ok(health, `Server failed to become ready: ${output}`);
        assert.equal(health.success, true);
        assert.equal(health.port, port);
        const response = await fetch(`${baseUrl}/activity/state`);
        assert.equal(response.status, 200);
        const state = await response.json();
        assert.equal(state.connected, false);
        assert.equal(state.activity, null);
        // Malformed JSON must be rejected before it reaches Discord IPC.
        const invalid = await fetch(`${baseUrl}/activity`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: "{"
        });
        assert.equal(invalid.status, 400);
    } finally {
        if (child && child.exitCode === null) {
            const exited = new Promise((resolve) => child.once("exit", resolve));
            child.kill();
            await exited;
        }
        fs.rmSync(directory, { recursive: true, force: true });
    }
});
