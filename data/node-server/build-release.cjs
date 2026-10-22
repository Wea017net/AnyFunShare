const fs = require("node:fs");
const path = require("node:path");
const { execFileSync } = require("node:child_process");
const { buildSync } = require("esbuild");
const { inject } = require("postject");
const { assertSupportedRuntime } = require("./runtime-version.cjs");

async function build() {
    assertSupportedRuntime();
    if (process.platform !== "win32" || process.arch !== "x64") {
        throw new Error("Build the release server on Windows x64.");
    }
    const root = __dirname;
    const buildDirectory = path.join(root, ".build");
    fs.mkdirSync(buildDirectory, { recursive: true });
    const bundle = path.join(buildDirectory, "server.cjs");
    const blob = path.join(buildDirectory, "server.blob");
    const config = path.join(buildDirectory, "sea-config.json");
    const executable = path.join(buildDirectory, "afs_server.exe");
    buildSync({
        entryPoints: [path.join(root, "afs_server.js")],
        outfile: bundle,
        bundle: true,
        platform: "node",
        target: "node24",
        format: "cjs",
        legalComments: "eof"
    });
    fs.writeFileSync(config, JSON.stringify({
        main: bundle,
        output: blob,
        disableExperimentalSEAWarning: true,
        useSnapshot: false,
        useCodeCache: false,
        execArgvExtension: "none"
    }));
    execFileSync(process.execPath, ["--experimental-sea-config", config], { stdio: "inherit" });
    fs.copyFileSync(process.execPath, executable);
    await inject(executable, "NODE_SEA_BLOB", fs.readFileSync(blob), {
        sentinelFuse: "NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2"
    });
    fs.copyFileSync(executable, path.join(root, "afs_server.exe"));
    console.log(`Built afs_server.exe with Node.js ${process.versions.node}`);
}

build().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
