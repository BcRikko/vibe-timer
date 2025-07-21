import SwiftUI
import UserNotifications

struct ContentView: View {
    @StateObject private var timerManager = TimerManager()
    @State private var showingCustomTimeView = false
    @State private var isPomodorMode = false
    
    var body: some View {
        VStack(spacing: 20) {
            // ヘッダー
            HStack {
                Text("Vibe Timer")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    isPomodorMode.toggle()
                }) {
                    Image(systemName: isPomodorMode ? "brain.head.profile" : "timer")
                        .foregroundColor(isPomodorMode ? .orange : .blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)
            
            // タイマー表示
            TimerDisplayView(timeRemaining: timerManager.timeRemaining)
            
            // 円形スライダー（カスタム時間設定時のみ表示）
            if showingCustomTimeView {
                CircularSliderView(
                    value: Binding(
                        get: { Double(timerManager.selectedMinutes) },
                        set: { timerManager.selectedMinutes = Int($0) }
                    ),
                    maxValue: 60
                )
                .frame(width: 200, height: 200)
            }
            
            // プリセット時間ボタン
            if !showingCustomTimeView {
                PresetTimeButtonsView(
                    timerManager: timerManager,
                    isPomodorMode: isPomodorMode,
                    showingCustomTimeView: $showingCustomTimeView
                )
            }
            
            // コントロールボタン
            ControlButtonsView(
                timerManager: timerManager,
                showingCustomTimeView: $showingCustomTimeView
            )
            
            // 終了ボタン
            Button("アプリを終了") {
                NSApplication.shared.terminate(nil)
            }
            .foregroundColor(.red)
            .padding(.top)
        }
        .padding()
        .frame(width: 320, height: 400)
        .background(LiquidGlassBackground())
        .onAppear {
            requestNotificationPermission()
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
}

struct LiquidGlassBackground: View {
    var body: some View {
        ZStack {
            // 半透明の背景
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
            
            // ガラス効果のオーバーレイ
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.white.opacity(0.3), location: 0),
                    .init(color: Color.white.opacity(0.1), location: 0.5),
                    .init(color: Color.white.opacity(0.2), location: 1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            )
        }
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
