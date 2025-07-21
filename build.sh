#!/bin/bash

# Vibe Timer ビルドスクリプト

set -e

echo "🔨 Vibe Timer をビルドしています..."

# プロジェクトディレクトリに移動
cd "$(dirname "$0")"

# Xcode がインストールされているかチェック
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode がインストールされていません。App Store からインストールしてください。"
    exit 1
fi

# ビルドディレクトリをクリーンアップ
echo "🧹 ビルドディレクトリをクリーンアップしています..."
rm -rf build
rm -rf VibeTimer.app
rm -rf VibeTimer.dmg

# プロジェクトをビルド
echo "🔨 プロジェクトをビルドしています..."
xcodebuild -project VibeTimer.xcodeproj \
    -scheme VibeTimer \
    -configuration Release \
    -derivedDataPath build \
    -quiet

# アプリケーションをコピー
echo "📱 アプリケーションをコピーしています..."
cp -R "build/Build/Products/Release/VibeTimer.app" ./

# DMG を作成
echo "📦 DMG ファイルを作成しています..."
hdiutil create -volname "Vibe Timer" \
    -srcfolder VibeTimer.app \
    -ov \
    -format UDZO \
    VibeTimer.dmg

echo "✅ ビルドが完了しました！"
echo "📄 出力ファイル:"
echo "   - VibeTimer.app (アプリケーション)"
echo "   - VibeTimer.dmg (配布用)"

# ファイルサイズを表示
if [[ -f "VibeTimer.dmg" ]]; then
    echo "📊 DMG ファイルサイズ: $(du -h VibeTimer.dmg | cut -f1)"
fi

echo "🎉 完了！"
