<p align="center">
  <img src="data/assets/app_icon.png" width="150" height="150" alt="AnyFunShare Icon">
</p>

<h1 align="center">AnyFunShare</h1>
<p align="center">楽しいこと、なんでも共有しよう</p>
2026年度 情報表現入門 オリジナルアプリ制作課題 成果物<br>2026 Introduction to information representation: Original App Development Assignment


# 概要
今自分がやっていることを自由に設定して Discord のアクティビティに表示、およびその時間を記録することができるアプリケーション

## 機能

- プリセットからアクティビティの種類を選択
- `Details`, `State` を自由に入力
- アクティビティを表示している時間を自動的に記録して集計

## 動作環境

- Processing 4
- Node.js 24
- Discord デスクトップ アプリ


## 補足説明・トラブルシューティング

- Discord のデスクトップアプリに対して通信を行うため、ブラウザ版 Discord では使用できません。
- アクティビティが表示されない場合、Discord 側の設定より、`アクティビティのプライバシー` → `アクティビティを共有` がオンになっていることを確認してください。
- VSCode の Discord Rich Presence 拡張機能や Rich Presence 対応ゲームなど、他のアプリケーションがアクティビティ情報を送信している状態だと本アプリが正常に動作しない可能性があります。無効化・終了を行ったうえで本アプリを実行してください。
- アプリがクラッシュしてしまった場合、Discord と通信を行う内部のサーバープロセスは終了されずに残ってしまう場合があります。その場合、同梱している `0_kill-server.bat` を実行してください。`afs_server.exe` を強制的に終了します。
- Discord との通信には Node.js を使用しています。Node.js がインストールされていない環境でも動作するように Windows 実行ファイル形式 (.exe) にパッケージ化しています。
- macOS, Linux での動作はサポートしていません。なお、Node.js がインストールされた環境であれば、`data` フォルダ内にある `config.json` の `ServerType` を 初期値の `release` から `debug` に書き換えることでサーバープロセスをパッケージ済みの `afs_server.exe` ではなく `afs_server.js` で起動させることができます。
- Processing と Node.js 間の通信には `localhost:3005` をデフォルトで使用しています。もしポートが競合してしまう場合は、`config.json` の `Port` を任意の値に変更してください。

- 制作者は Processing および Node.js の初学者です。上記の説明が誤っている可能性がありますが、ご了承ください。
- 本プロジェクトは調整を加えた後、後日 GitHub にて公開予定です。リポジトリのリンクは `https://github.com/Wea017net/AnyFunShare` となる予定です。

## ライセンス

- 同梱フォント `源真ゴシック` は [SIL Open Font License 1.1](data/assets/font/GenShinGothic/SIL_Open_Font_License_1.1.txt) に従います。
