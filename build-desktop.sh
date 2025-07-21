#!/bin/bash

# macOSアプリバンドル手動作成スクリプト

set -e

echo "🔨 VibeTimer デスクトップアプリを手動作成しています..."

APP_NAME="VibeTimer"
BUNDLE_DIR="${APP_NAME}.app"

# 既存のアプリバンドルを削除
rm -rf "$BUNDLE_DIR"

# アプリバンドル構造を作成
mkdir -p "$BUNDLE_DIR/Contents/MacOS"
mkdir -p "$BUNDLE_DIR/Contents/Resources"

echo "📱 アプリバンドル構造を作成しました"

# SwiftUIアプリ用の簡単なWrapper作成
cat > "$BUNDLE_DIR/Contents/MacOS/$APP_NAME" << 'EOF'
#!/bin/bash
# VibeTimer Wrapper Script

cd "$(dirname "$0")/../Resources"

# GUIダイアログでタイマー時間を取得
TIME_INPUT=$(osascript -e 'display dialog "タイマー時間を分で入力してください:" default answer "3" with title "Vibe Timer"' -e 'text returned of result' 2>/dev/null || echo "3")

# バックグラウンドでタイマーを実行
osascript << EOD
display notification "タイマーを開始しました ($TIME_INPUT 分)" with title "Vibe Timer" subtitle "バックグラウンドで実行中..."

delay $(($TIME_INPUT * 60))

display notification "⏰ 時間になりました！" with title "Vibe Timer" subtitle "$TIME_INPUT 分経過" sound name "Glass"

display dialog "⏰ タイマー完了！\\n$TIME_INPUT 分が経過しました。" with title "Vibe Timer" buttons {"OK"} default button "OK"
EOD
EOF

# 実行権限を付与
chmod +x "$BUNDLE_DIR/Contents/MacOS/$APP_NAME"

# Info.plistを作成
cat > "$BUNDLE_DIR/Contents/Info.plist" << 'EOF'
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
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.productivity</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSRequiresAquaSystemAppearance</key>
    <false/>
</dict>
</plist>
EOF

echo "✅ $BUNDLE_DIR が作成されました！"
echo "🚀 使用方法: Finderで $BUNDLE_DIR をダブルクリック"
echo "💡 または: open $BUNDLE_DIR"

# DMGファイルも作成
if command -v hdiutil &> /dev/null; then
    echo "📦 DMGファイルを作成しています..."
    hdiutil create -volname "Vibe Timer" \
        -srcfolder "$BUNDLE_DIR" \
        -ov \
        -format UDZO \
        "VibeTimer-Desktop.dmg"
    
    if [[ -f "VibeTimer-Desktop.dmg" ]]; then
        echo "📊 DMG ファイルサイズ: $(du -h VibeTimer-Desktop.dmg | cut -f1)"
    fi
fi

echo "🎉 デスクトップアプリの作成が完了しました！"
