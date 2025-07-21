import Foundation

print("🎯 Vibe Timer - Command Line Edition")
print("⏱️  シンプルなコマンドラインタイマー")
print("")

// デフォルト3分（180秒）
let defaultSeconds = 180
var timerSeconds = defaultSeconds

// コマンドライン引数から時間を取得
if CommandLine.arguments.count > 1 {
    if let minutes = Int(CommandLine.arguments[1]) {
        timerSeconds = minutes * 60
        print("⏰ タイマーを \(minutes) 分に設定しました")
    } else {
        print("❌ 無効な分数です。デフォルト3分を使用します。")
    }
} else {
    print("⏰ デフォルト3分タイマーを開始します")
    print("💡 使用方法: ./VibeTimer [分数]")
}

print("🚀 タイマー開始! \(timerSeconds/60)分\(timerSeconds%60)秒")
print("⏹️  停止するには Ctrl+C を押してください")
print("")

// タイマー実行
var remaining = timerSeconds
let startTime = Date()

while remaining > 0 {
    let minutes = remaining / 60
    let seconds = remaining % 60
    
    // 進捗バーを作成
    let progress = Double(timerSeconds - remaining) / Double(timerSeconds)
    let progressWidth = 20
    let filledWidth = Int(progress * Double(progressWidth))
    let progressBar = String(repeating: "█", count: filledWidth) + 
                     String(repeating: "░", count: progressWidth - filledWidth)
    
    // 画面をクリアして時間を表示
    print("\u{1B}[2J\u{1B}[H", terminator: "") // 画面クリア
    print("🎯 Vibe Timer")
    print("")
    print("⏰ 残り時間: \(String(format: "%02d:%02d", minutes, seconds))")
    print("📊 進捗: [\(progressBar)] \(Int(progress * 100))%")
    print("")
    print("⏹️  停止するには Ctrl+C を押してください")
    
    sleep(1)
    remaining -= 1
}

// タイマー完了
print("\u{1B}[2J\u{1B}[H", terminator: "") // 画面クリア
print("🎉 タイマー完了!")
print("⏰ \(timerSeconds/60)分\(timerSeconds%60)秒 経過しました")
print("🔔 時間になりました！")

// システム音を鳴らす（macOSの場合）
let task = Process()
task.launchPath = "/usr/bin/afplay"
task.arguments = ["/System/Library/Sounds/Glass.aiff"]
try? task.run()

print("")
print("✨ お疲れ様でした！")
