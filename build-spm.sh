#!/bin/bash

# Vibe Timer - Swift Package Manager ビルドスクリプト

set -e

echo "🔨 Vibe Timer をSwift Package Managerでビルドしています..."

# プロジェクトディレクトリに移動
cd "$(dirname "$0")"

# Swift Package Manager が使用可能かチェック
if ! command -v swift &> /dev/null; then
    echo "❌ Swift が見つかりません。Xcode Command Line Tools をインストールしてください。"
    echo "   xcode-select --install"
    exit 1
fi

echo "🧹 クリーンアップしています..."
swift package clean

echo "🔨 パッケージをビルドしています..."
swift build -c release

echo "📱 実行可能ファイルを確認しています..."
if [[ -f ".build/release/VibeTimer" ]]; then
    echo "✅ ビルドが完了しました！"
    echo "📄 出力ファイル:"
    echo "   - .build/release/VibeTimer (実行可能ファイル)"
    echo "💡 実行方法: ./.build/release/VibeTimer"
else
    echo "❌ ビルドに失敗しました。"
    exit 1
fi

echo "🎉 完了！"
