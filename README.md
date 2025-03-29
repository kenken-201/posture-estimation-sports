# Flutter Video Frame Extraction and Pose Estimation App

このFlutterアプリは、ユーザーが動画を選択し、その動画を秒間1枚ずつコマ送りして画像リストを生成し、各画像に対して姿勢推定（Pose Estimation）を実行し、その結果を一覧表示する機能と、ローカルで立ち上げたDjangoサーバに動画をPOSTして、姿勢推定された動画をGETして表示する機能を持ったアプリケーションです。以下に、このアプリのセットアップ方法、使用方法、およびその他の関連情報を説明します。

## 機能

- 動画の選択と読み込み
- 動画を秒間1枚のペースでコマ送りして画像を抽出
- 抽出した画像に対して姿勢推定を実行
- 姿勢推定結果をリストとして表示

## 前提条件

このアプリを動作させるためには、以下のものが必要です。

- Flutter SDK（最新の安定版を推奨）
- Android Studio または Visual Studio Code（任意のFlutter対応IDE）
- Android または iOSデバイス（またはエミュレーター/シミュレーター）

## インストール

1. このリポジトリをクローンまたはダウンロードします。

```bash
git clone https://github.com/kensak222/posture-estimation-sports.git
```

2. 依存関係をインストールします。

```bash
make pub-get
```

3. 使用するエミュレーターまたは実機を準備し、アプリを実行します。

```bash
make run
```

## 使用方法

1. アプリを起動します。
2. 「動画を選択」ボタンをタップして、デバイス内の動画ファイルを選択します。
3. 動画が読み込まれ、コマ送りで画像が自動的に抽出されます。
4. 各画像に対して、姿勢推定（Pose Estimation）が実行され、結果として画像上に推定された姿勢が表示されます。
5. 画面に表示された画像をスクロールして、姿勢推定結果を確認します。

## 主な技術スタック

- **Flutter**: クロスプラットフォームのアプリケーションフレームワーク
- **Dart**: Flutterのプログラミング言語
- **FFmpeg**: 動画から画像を抽出するためのライブラリ（プラグイン利用）
- **MoveNet**: 姿勢推定を行うためのモデル
- **flutter_ffmpeg**: 動画処理を行うためのFlutter用FFmpegプラグイン
- **tflite_flutter**: 姿勢推定を行うためのFlutter用ライブラリ
- **riverpod**: 状態管理やDIを行うためのFlutter用ライブラリ
- **flutter_hooks**: 画面内の状態管理を行うためのFlutter用ライブラリ

## 動作の流れ

### 端末上での姿勢推定

1. ユーザーが動画を選択する。
2. 動画を解析し、指定したフレームレート（秒間1枚）で画像を抽出する。
3. 抽出した各画像に対して、TensorFlow Liteモデルを使用して姿勢推定を実行する。
4. 姿勢推定の結果を画像に重ねて表示する。

### サーバ上で姿勢推定

1. ユーザーが動画を選択する。
2. 選択した動画をサーバにPOSTする。
3. サーバ上で動画を解析し、姿勢推定を施す。
4. サーバ上で姿勢推定が成功したら、動画のパスが返却される。
5. 動画のパスを指定して動画を再生する。

## 注意事項

- 動画の長さや解像度によっては、処理に時間がかかる場合があります。
- モバイルデバイスでは、特に高解像度の動画の場合、パフォーマンスに影響が出ることがあります。低解像度での処理を検討してください。

## 開発の進行状況

- 動画の選択と解析機能は完成しています。
- 姿勢推定機能の精度向上中。
- UI/UXの改善予定。

## Git Commit Hook for `make analyze`

<details>

<summary>pre-commitの設定</summary>

このプロジェクトでは、Git のコミット前に `make analyze` を自動的に実行し、静的解析でエラーが発生した場合にコミットを拒否する仕組みを導入しています。この仕組みを利用することで、コード品質を維持し、エラーを早期に発見できます。

## 使用方法

### 1. `pre-commit` フックの設定

プロジェクトのルートディレクトリにある `.git/hooks/pre-commit` ファイルを以下の内容で作成します。

```bash
#!/bin/bash

# 現在のブランチ名を取得
current_branch=$(git symbolic-ref --short HEAD)

# 'main' ブランチに対するコミットを拒否
if [ "$current_branch" == "main" ]; then
  echo "Error: You cannot commit directly to the 'main' branch."
  exit 1  # コミットを中止
fi

# make analyze を実行して、エラーがあればコミットを中止
echo "Running 'make analyze' before commit..."
make format
make analyze

# make analyze がエラー終了コード（非0）を返した場合、コミットを中止
if [ $? -ne 0 ]; then
  echo "Error: 'make analyze' failed. Commit aborted."
  exit 1  # コミットを中止
fi

# 成功した場合はコミットを続行
exit 0
```

### 2. `pre-commit` ファイルに実行権限を付与

`pre-commit` フックに実行権限を付与します。以下のコマンドを実行してください。

```bash
chmod +x .git/hooks/pre-commit
```

### 3. コミット時の確認

設定後、`git commit` を実行すると、コミット前に `make analyze` が実行されます。もし静的解析にエラーがあった場合、コミットは中止され、エラーメッセージが表示されます。解析が成功した場合のみ、コミットが続行されます。

## 注意事項

- `pre-commit` フックはローカルリポジトリに設定されるため、他の開発者がリポジトリをクローンした場合には、同様の設定が必要です。
- コミット前に必ず静的解析を実行することで、品質の高いコードを維持できます。

## まとめ

- `make analyze` をコミット前に自動で実行することで、エラーがあった場合にコミットを拒否します。
- `pre-commit` フックを設定することで、全員が同じ静的解析ルールを守りながら開発できます。

## 説明

- **`pre-commit` フック**：このフックは、`git commit` 実行前に自動的に `make analyze` を実行し、エラーが発生した場合にコミットを拒否します。
- **使い方**：
    1. `.git/hooks/pre-commit` を作成し、指定のスクリプトを追加。
    2. `chmod +x .git/hooks/pre-commit` で実行権限を付与。
    3. コミット時に自動で静的解析が行われ、エラーがあればコミットを中止。
- **注意点**：
    - この仕組みはローカルに設定されるため、他の開発者が同じ設定を使う場合は、手動で設定するか、フック管理ツール（`pre-commit` など）を使う方法もあります。

</details>

## サンプル

端末上での姿勢推定は精度が悪い（おそらく前処理が良くない）ので、改善したい。  
動画は [https://www.pexels.com/](https://www.pexels.com/) より拝借。  

| 端末上で姿勢推定 | サーバ上で姿勢推定 |
| -- | ---- |
| ![unnamed](https://github.com/user-attachments/assets/642ce738-42ef-4d08-acfd-5b9618ecae74) | ![姿勢推定動画](https://github.com/user-attachments/assets/01f083d4-812e-48e2-a266-791b94d011eb) |
