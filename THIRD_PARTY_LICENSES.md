# Third-Party Licenses

This repository includes third-party components that are licensed under their own terms.

## 1) Font

- Name: GenShinGothic (source files under `data/assets/font/GenShinGothic`)
- License: SIL Open Font License 1.1 (OFL-1.1)
- License text: `data/assets/font/GenShinGothic/SIL_Open_Font_License_1.1.txt`

## 2) Node.js server dependencies

The server project at `data/node-server` depends on npm packages.

Direct dependencies in `data/node-server/package.json`:

- `discord-ipc`: MIT
- `express`: MIT
- `net`: MIT

Transitive dependencies (from `data/node-server/package-lock.json`) include licenses such as:

- MIT
- ISC
- BSD-3-Clause

Examples:

- `qs`: BSD-3-Clause
- `inherits`: ISC
- `once`: ISC

## Notes

- This file is an informational summary for distribution.
- The source of truth for npm package versions and licenses is `data/node-server/package-lock.json`.
- When redistributing binaries such as `data/node-server/afs_server.exe`, keep third-party notices and license files together with the distribution.
