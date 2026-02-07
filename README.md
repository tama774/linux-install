# Linux インストールスクリプト

このリポジトリは、実機への Linux 新規インストール後のセットアップを簡略化するためのスクリプト群です。
基本的なツールのインストール、ハードウェアの検証、そして様々なディストリビューションやセルフホストアプリケーションを試すための環境構築を自動化することを目指しています。

## 使い方

1.  このリポジトリをクローンします:
    ```bash
    git clone https://github.com/tama774/linux-install.git
    cd linux-install
    ```

2.  メインのインストールスクリプトを実行します:
    ```bash
    ./install.sh
    ```

3.  メニューから実行したいオプションを選択してください。

## 機能と役割

### 1. CLI ツールのインストール (Install CLI Tools)
基本的なコマンドラインツール群をインストールします。
-   **Debian/Ubuntu**: `git`, `curl`, `wget`, `vim`, `htop`, `tmux`, `zsh`
-   **Arch Linux**: `git`, `curl`, `wget`, `vim`, `htop`, `tmux`, `zsh`

### 2. 環境設定 (Setup Preferences)
ターミナルでの作業を快適にするためのユーザー設定を行います。
-   **Caps Lock と Control の入れ替え**:
    -   `~/.profile` に `/usr/bin/setxkbmap -option "ctrl:swapcaps"` を追加します。
    -   ログイン後 (X11環境) に、Caps Lock キーが Control キーとして動作するようになります。

### 3. ハードウェアチェック (Check Hardware) [実装予定]
-   SSD の健全性確認、パフォーマンスベンチマーク、ドライバの状態確認などを行うスクリプト。

### 4. セルフホストアプリ (Self-Hosted Apps) [実装予定]
-   検証用の各種セルフホストアプリケーションを簡単にインストール・アンインストールする機能。

## ディレクトリ構成
-   `install.sh`: メインのエントリーポイントとなるスクリプト。
-   `scripts/`: 機能ごとにモジュール化されたスクリプト群。
    -   `common/utils.sh`: ヘルパー関数とディストリビューション検出ロジック。
    -   `install-cli.sh`: CLI ツールインストールのロジック。
    -   `setup-preferences.sh`: ユーザー設定適用のロジック。
