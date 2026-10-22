<p align="center">
  <img src="data/assets/app_icon.png" width="150" height="150" alt="AnyFunShare Icon">
</p>

<h1 align="center">AnyFunShare</h1>
<p align="center">楽しいこと、なんでも共有しよう</p>
2026年度 情報表現入門 オリジナルアプリ制作課題 成果物<br>2026 Introduction to information representation: Original App Development Assignment

## ダウンロード
Releases より最新のリリースをダウンロードできます：<br>https://github.com/Wea017net/AnyFunShare/releases

## 概要
今自分がやっていることを自由に設定して Discord のアクティビティに表示、およびその時間を記録することができるアプリケーション

## 機能

- プリセットからアクティビティの種類を選択
- `Details`, `State` を自由に入力
- アクティビティを表示している時間を自動的に記録して集計

## 動作環境

- Processing 4
- Node.js 24.22.1 以降の 24.x（通常利用では修正版ランタイムを同梱）
- Discord デスクトップ アプリ


## 補足説明・トラブルシューティング

- Discord のデスクトップアプリに対して通信を行うため、ブラウザ版 Discord では使用できません。
- アクティビティが表示されない場合、Discord 側の設定より、`アクティビティのプライバシー` → `アクティビティを共有` がオンになっていることを確認してください。
- VSCode の Discord Rich Presence 拡張機能や Rich Presence 対応ゲームなど、他のアプリケーションがアクティビティ情報を送信している状態だと本アプリが正常に動作しない可能性があります。無効化・終了を行ったうえで本アプリを実行してください。
- アプリがクラッシュしてしまった場合、Discord と通信を行う内部のサーバープロセスは終了されずに残ってしまう場合があります。その場合、同梱している `kill-server.bat` を実行してください。`afs_server.exe` を強制的に終了します。
- Discord との通信には Node.js を使用しています。Node.js がインストールされていない環境でも動作するように Windows 実行ファイル形式 (.exe) にパッケージ化しています。
- macOS, Linux での動作はサポートしていません。なお、Node.js がインストールされた環境であれば、`data` フォルダ内にある `config.json` の `ServerType` を 初期値の `release` から `debug` に書き換えることでサーバープロセスをパッケージ済みの `afs_server.exe` ではなく `afs_server.js` で起動させることができます。
- Processing と Node.js 間の通信には `localhost:3005` をデフォルトで使用しています。もしポートが競合してしまう場合は、`config.json` の `Port` を任意の値に変更してください。

## サーバーのビルド（Windows x64）

2026年10月の [Node.js セキュリティ更新](https://nodejs.org/en/blog/vulnerability/october-2026-security-releases) に対応し、同梱サーバーは Node.js 24.22.1 でビルドしています。デバッグ起動でも 24.22.1 以降の 24.x を使用してください。古いランタイムではサーバーの起動を拒否します。

`data/node-server` で以下を実行してください。

```powershell
npm ci
npm run build
npm test
```

ビルドは `.node-version` に指定した公式 Windows x64 バイナリを取得し、SHA-256 を検証してから Node.js SEA 形式の `afs_server.exe` を生成します。依存パッケージも実行ファイルへ同梱されます。ビルドにはインターネット接続が必要です。

同梱ランタイムの確認は `./afs_server.exe --runtime-version` で行えます。今後ランタイムを更新する場合は `.node-version`、`build-release.ps1` の公式 SHA-256、`package.json` の `engines`、`runtime-version.cjs` の最低バージョンを合わせて更新し、再ビルドしてください。

## ライセンス

- 本リポジトリ内の自作ソースコードは [MIT License](LICENSE) の下で公開します。
- サードパーティコンポーネントのライセンス一覧は [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md) を参照してください。
- 同梱フォント `源真ゴシック` は [SIL Open Font License 1.1](data/assets/font/GenShinGothic/SIL_Open_Font_License_1.1.txt) に従います。
