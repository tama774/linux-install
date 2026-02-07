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
    (オプションを選択すると、その処理を実行してスクリプトは終了します)

## 機能と役割

### 1. CLI ツールのインストール (Install CLI Tools)
基本的なコマンドラインツール群をインストールします。
-   **Linux Mint Xfce**: `git`, `curl`, `wget`, `vim`, `emacs`, `htop`, `tmux`, `zsh`, `smartmontools`, `tlp`, `imagemagick`, `fzf`

### 2. 環境設定 (Setup Preferences)
ターミナルでの作業を快適にするためのユーザー設定を行います。
-   **Caps Lock と Control の入れ替え**:
    -   `~/.profile` に `/usr/bin/setxkbmap -option "ctrl:swapcaps"` を追加します。
    -   ログイン後 (X11環境) に、Caps Lock キーが Control キーとして動作するようになります。

### 3. ハードウェアチェック (Check Hardware)
ハードウェア情報を収集し、レポートファイルとして保存します。
-   取得情報:
    -   CPU情報 (`lscpu`)
    -   メモリ情報 (`free`)
    -   ディスク使用量 (`df`)
    -   ブロックデバイス情報 (`lsblk`)
    -   ネットワーク情報 (`ip addr`)
    -   PCIデバイス情報 (`lspci` - VGA/Network)
    -   温度情報 (`sensors` - あれがインストールされている場合)
    -   SMARTステータス (`smartctl` - 検出された全ディスク `/dev/sd*`, `/dev/nvme*`)
-   レポートは `hardware_reports/` ディレクトリに保存されます。

### 4. Docker のインストール (Install Docker)
-   公式リポジトリから Docker Engine と Docker Compose プラグインをインストールします。
-   現在のユーザーを `docker` グループに追加します (sudoなしで実行可能にするため)。

### 5. Node.js のインストール (Install Node.js)
-   **fnm (Fast Node Manager)** を使用して Node.js 環境を構築します。
-   最新の LTS バージョンをインストールし、`.bashrc` / `.zshrc` に設定を追加します。

### 6. Go & ghq のインストール (Install Go & ghq)
-   **goenv** を使用して Go 環境を構築します。
-   最新の Go バージョンをインストールします。
-   リポジトリ管理ツール **ghq** を `go install` でインストールします。
-   **fzf** と連携したエイリアス `g` を設定します:
    -   `alias g='cd $(ghq root)/$(ghq list | fzf)'`
    -   これにより、`g` コマンドでリポジトリをインクリメンタルサーチして移動できるようになります。

### 7. セルフホストアプリ (Self-Hosted Apps) [実装予定]
-   検証用の各種セルフホストアプリケーションを簡単にインストール・アンインストールする機能。

## ディレクトリ構成
-   `install.sh`: メインのエントリーポイントとなるスクリプト。
-   `scripts/`: 機能ごとにモジュール化されたスクリプト群。
    -   `common/utils.sh`: ヘルパー関数とディストリビューション検出ロジック。
    -   `install-cli.sh`: CLI ツールインストールのロジック。
    -   `setup-preferences.sh`: ユーザー設定適用のロジック。
    -   `check-hardware.sh`: ハードウェア情報収集とレポート生成のロジック。
