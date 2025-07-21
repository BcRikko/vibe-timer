#!/bin/bash

# Vibe Timer - Command Line Tools ビルドスクリプト

set -e

echo "🔨 Vibe Timer をCommand Line Toolsでビルドしています..."

# プロジェクトディレクトリに移動
cd "$(dirname "$0")"

# Swift コンパイラが使用可能かチェック
if ! command -v swiftc &> /dev/null; then
    echo "❌ Swift コンパイラが見つかりません。Xcode Command Line Tools をインストールしてください。"
    echo "   xcode-select --install"
    exit 1
fi

# ビルドディレクトリをクリーンアップ
echo "🧹 ビルドディレクトリをクリーンアップしています..."
rm -rf build-cli
rm -rf VibeTimer.app
rm -rf VibeTimer.dmg

# ビルドディレクトリを作成
mkdir -p build-cli

echo "🔨 Swiftファイルをコンパイルしています..."

# macOS用にSwiftファイルをコンパイル
swiftc \
    -target x86_64-apple-macosx14.0 \
    -import-objc-header VibeTimer/BridgingHeader.h \
    -framework SwiftUI \
    -framework Cocoa \
    -framework Foundation \
    -framework UserNotifications \
    -O \
    -o build-cli/VibeTimer \
    VibeTimer/*.swift

# アプリバンドルを作成
echo "📱 アプリバンドルを作成しています..."
mkdir -p "VibeTimer.app/Contents/MacOS"
mkdir -p "VibeTimer.app/Contents/Resources"

# 実行ファイルをコピー
cp build-cli/VibeTimer "VibeTimer.app/Contents/MacOS/"

# Info.plist を作成
cat > "VibeTimer.app/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>VibeTimer</string>
    <key>CFBundleIdentifier</key>
    <string>com.vibetimer.VibeTimer</string>
    <key>CFBundleName</key>
    <string>Vibe Timer</string>
    <key>CFBundleDisplayName</key>
    <string>Vibe Timer</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.productivity</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

# 実行権限を付与
chmod +x "VibeTimer.app/Contents/MacOS/VibeTimer"

echo "✅ アプリバンドルが作成されました！"
echo "📄 出力ファイル:"
echo "   - VibeTimer.app (アプリケーション)"

# DMG を作成（オプション）
if command -v hdiutil &> /dev/null; then
    echo "📦 DMG ファイルを作成しています..."
    hdiutil create -volname "Vibe Timer" \
        -srcfolder VibeTimer.app \
        -ov \
        -format UDZO \
        VibeTimer.dmg
    
    if [[ -f "VibeTimer.dmg" ]]; then
        echo "📊 DMG ファイルサイズ: $(du -h VibeTimer.dmg | cut -f1)"
    fi
fi

echo "🎉 完了！"
echo "💡 ヒント: VibeTimer.app をダブルクリックで実行できます。"
