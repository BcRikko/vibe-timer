import SwiftUI

struct TimerDisplayView: View {
    let timeRemaining: TimeInterval
    
    var body: some View {
        VStack(spacing: 8) {
            // 時間表示
            Text(timeString(from: timeRemaining))
                .font(.system(size: 48, weight: .thin, design: .monospaced))
                .foregroundColor(.primary)
            
            // プログレスリング
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 4)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: progressValue)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.cyan]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: progressValue)
            }
        }
    }
    
    private var progressValue: Double {
        // この値は実際の進捗に基づいて計算する必要があります
        // 現在は簡単な例として固定値を使用
        return min(1.0, max(0.0, timeRemaining / 180.0))
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct CircularSliderView: View {
    @Binding var value: Double
    let maxValue: Double
    
    @State private var isDragging = false
    @State private var dragAngle: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2 - 20
            
            ZStack {
                // 背景サークル
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 8)
                
                // プログレスサークル
                Circle()
                    .trim(from: 0, to: value / maxValue)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.cyan]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                // ハンドル
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(radius: 4)
                    .position(
                        x: center.x + cos(angleForValue(value) - .pi / 2) * radius,
                        y: center.y + sin(angleForValue(value) - .pi / 2) * radius
                    )
                
                // 中央の値表示
                VStack {
                    Text("\(Int(value))")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("分")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { gestureValue in
                        let vector = CGVector(
                            dx: gestureValue.location.x - center.x,
                            dy: gestureValue.location.y - center.y
                        )
                        let angle = atan2(vector.dy, vector.dx) + .pi / 2
                        let normalizedAngle = angle < 0 ? angle + 2 * .pi : angle
                        
                        let newValue = (normalizedAngle / (2 * .pi)) * maxValue
                        value = min(maxValue, max(0, newValue))
                    }
            )
        }
    }
    
    private func angleForValue(_ value: Double) -> Double {
        return (value / maxValue) * 2 * .pi
    }
}

struct PresetTimeButtonsView: View {
    let timerManager: TimerManager
    let isPomodorMode: Bool
    @Binding var showingCustomTimeView: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            if isPomodorMode {
                // ポモドーロモードのボタン
                HStack(spacing: 16) {
                    PresetButton(title: "作業", subtitle: "\(timerManager.pomodoroWorkTime)分") {
                        timerManager.setTime(minutes: timerManager.pomodoroWorkTime)
                    }
                    
                    PresetButton(title: "短休憩", subtitle: "\(timerManager.pomodoroShortBreak)分") {
                        timerManager.setTime(minutes: timerManager.pomodoroShortBreak)
                    }
                    
                    PresetButton(title: "長休憩", subtitle: "\(timerManager.pomodoroLongBreak)分") {
                        timerManager.setTime(minutes: timerManager.pomodoroLongBreak)
                    }
                }
            } else {
                // 通常モードのボタン
                HStack(spacing: 16) {
                    PresetButton(title: "3分", subtitle: "") {
                        timerManager.setTime(minutes: 3)
                    }
                    
                    PresetButton(title: "5分", subtitle: "") {
                        timerManager.setTime(minutes: 5)
                    }
                    
                    PresetButton(title: "10分", subtitle: "") {
                        timerManager.setTime(minutes: 10)
                    }
                }
            }
            
            // カスタム時間ボタン
            Button("カスタム時間") {
                showingCustomTimeView.toggle()
            }
            .buttonStyle(GlassButtonStyle())
        }
    }
}

struct PresetButton: View {
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 60, height: 40)
        }
        .buttonStyle(GlassButtonStyle())
    }
}

struct ControlButtonsView: View {
    let timerManager: TimerManager
    @Binding var showingCustomTimeView: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            // 開始/停止ボタン
            Button(timerManager.isRunning ? "停止" : "開始") {
                if timerManager.isRunning {
                    timerManager.stopTimer()
                } else {
                    timerManager.startTimer()
                }
            }
            .buttonStyle(GlassButtonStyle(isPrimary: true))
            
            // リセットボタン
            Button("リセット") {
                timerManager.resetTimer()
            }
            .buttonStyle(GlassButtonStyle())
            
            // 戻るボタン（カスタム時間設定時のみ表示）
            if showingCustomTimeView {
                Button("戻る") {
                    showingCustomTimeView = false
                }
                .buttonStyle(GlassButtonStyle())
            }
        }
    }
}

struct GlassButtonStyle: ButtonStyle {
    let isPrimary: Bool
    
    init(isPrimary: Bool = false) {
        self.isPrimary = isPrimary
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isPrimary ?
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.4)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
            )
            .foregroundColor(isPrimary ? .white : .primary)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
