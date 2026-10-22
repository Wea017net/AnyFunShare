const MINIMUM_NODE_VERSION = "24.22.1";

function assertSupportedRuntime(version = process.versions.node) {
    const [major, minor, patch] = version.split(".").map(Number);
    if (major !== 24 || minor < 22 || (minor === 22 && patch < 1)) {
        throw new Error(`Node.js ${MINIMUM_NODE_VERSION} or later in the 24.x line is required (found ${version}).`);
    }
}

module.exports = { MINIMUM_NODE_VERSION, assertSupportedRuntime };
