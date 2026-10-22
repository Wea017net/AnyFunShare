const { test } = require("node:test");
const assert = require("node:assert/strict");
const { assertSupportedRuntime } = require("../runtime-version.cjs");

test("rejects runtimes predating the October 2026 security release", () => {
    for (const version of ["24.14.1", "24.18.0", "24.22.0", "22.23.3", "26.12.0"]) {
        assert.throws(() => assertSupportedRuntime(version), /24\.22\.1/);
    }
});

test("accepts the fixed runtime and subsequent Node.js 24 updates", () => {
    for (const version of ["24.22.1", "24.22.2", "24.23.0"]) {
        assert.doesNotThrow(() => assertSupportedRuntime(version));
    }
});
