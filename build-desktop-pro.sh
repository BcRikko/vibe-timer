#!/bin/bash

# Vibe Timer - Advanced Desktop App Builder

set -e

echo "🔨 Vibe Timer 高機能デスクトップアプリを作成しています..."

APP_NAME="VibeTimerPro"
BUNDLE_DIR="${APP_NAME}.app"

# 既存のアプリバンドルを削除
rm -rf "$BUNDLE_DIR"

# アプリバンドル構造を作成
mkdir -p "$BUNDLE_DIR/Contents/MacOS"
mkdir -p "$BUNDLE_DIR/Contents/Resources"

# SwiftUIライクな高機能アプリWrapper作成
cat > "$BUNDLE_DIR/Contents/MacOS/$APP_NAME" << 'EOF'
#!/bin/bash

# Vibe Timer Pro - Advanced Timer App

show_menu() {
    local choice
    choice=$(osascript << 'EOD'
tell application "System Events"
    set choices to {"3分タイマー", "5分タイマー", "10分タイマー", "ポモドーロ(25分)", "カスタム時間", "設定"}
    set selectedChoice to choose from list choices with title "Vibe Timer Pro" with prompt "タイマーを選択してください:" default items {"3分タイマー"}
    
    if selectedChoice is not false then
        return item 1 of selectedChoice
    else
        return "キャンセル"
    end if
end tell
EOD
)
    echo "$choice"
}

start_timer() {
    local minutes=$1
    local timer_name=$2
    
    osascript << EOD
    -- タイマー開始通知
    display notification "タイマーを開始しました ($minutes 分)" with title "Vibe Timer Pro" subtitle "$timer_name"
    
    -- メニューバーにタイマー表示（疑似的）
    set timer_seconds to $minutes * 60
    
    repeat while timer_seconds > 0
        set minutes_left to timer_seconds div 60
        set seconds_left to timer_seconds mod 60
        set time_display to (minutes_left as string) & ":" & (text -2 thru -1 of ("0" & seconds_left as string))
        
        -- 1秒待機
        delay 1
        set timer_seconds to timer_seconds - 1
        
        -- 10秒ごとに進捗通知
        if timer_seconds mod 10 = 0 and timer_seconds > 0 then
            display notification "残り " & time_display with title "Vibe Timer Pro" subtitle "$timer_name 実行中"
        end if
    end repeat
    
    -- 完了通知
    display notification "⏰ 時間になりました！" with title "Vibe Timer Pro" subtitle "$timer_name 完了" sound name "Glass"
    
    -- 完了ダイアログ
    display dialog "⏰ タイマー完了！\\n\\n$timer_name ($minutes 分) が終了しました。\\n\\nお疲れ様でした！" with title "Vibe Timer Pro" buttons {"OK", "もう一度"} default button "OK" with icon note
    
    set user_choice to button returned of result
    if user_choice is "もう一度" then
        my start_timer($minutes, "$timer_name")
    end if
EOD
}

# メインループ
while true; do
    choice=$(show_menu)
    
    case "$choice" in
        "3分タイマー")
            start_timer 3 "3分タイマー"
            ;;
        "5分タイマー")
            start_timer 5 "5分タイマー"
            ;;
        "10分タイマー")
            start_timer 10 "10分タイマー"
            ;;
        "ポモドーロ(25分)")
            start_timer 25 "ポモドーロセッション"
            ;;
        "カスタム時間")
            custom_time=$(osascript -e 'display dialog "タイマー時間を分で入力してください:" default answer "15" with title "Vibe Timer Pro - カスタム時間"' -e 'text returned of result' 2>/dev/null || echo "0")
            if [ "$custom_time" != "0" ] && [ "$custom_time" != "" ]; then
                start_timer "$custom_time" "カスタムタイマー"
            fi
            ;;
        "設定")
            osascript -e 'display dialog "Vibe Timer Pro v1.0\\n\\n機能:\\n• プリセットタイマー\\n• ポモドーロテクニック\\n• カスタム時間設定\\n• デスクトップ通知\\n• 音声アラート" with title "設定・情報" buttons {"OK"} default button "OK"'
            ;;
        *)
            exit 0
            ;;
    esac
done
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
    <string>VibeTimerPro</string>
    <key>CFBundleIdentifier</key>
    <string>com.vibetimer.VibeTimerPro</string>
    <key>CFBundleName</key>
    <string>Vibe Timer Pro</string>
    <key>CFBundleDisplayName</key>
    <string>Vibe Timer Pro</string>
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
    <key>LSUIElement</key>
    <false/>
</dict>
</plist>
EOF

echo "✅ $BUNDLE_DIR が作成されました！"

# DMGファイルも作成
if command -v hdiutil &> /dev/null; then
    echo "📦 DMGファイルを作成しています..."
    hdiutil create -volname "Vibe Timer Pro" \
        -srcfolder "$BUNDLE_DIR" \
        -ov \
        -format UDZO \
        "VibeTimerPro-Desktop.dmg"
    
    if [[ -f "VibeTimerPro-Desktop.dmg" ]]; then
        echo "📊 DMG ファイルサイズ: $(du -h VibeTimerPro-Desktop.dmg | cut -f1)"
    fi
fi

echo "🎉 高機能デスクトップアプリの作成が完了しました！"
echo "🚀 使用方法: open $BUNDLE_DIR"
