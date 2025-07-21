import SwiftUI
import Foundation
import UserNotifications

class TimerManager: ObservableObject {
    @Published var timeRemaining: TimeInterval = 180 // デフォルト3分
    @Published var isRunning = false
    @Published var selectedMinutes = 3
    
    // ポモドーロ設定
    @Published var pomodoroWorkTime = 25
    @Published var pomodoroShortBreak = 5
    @Published var pomodoroLongBreak = 15
    @Published var currentPomodoroSession = 0
    @Published var isWorkSession = true
    
    private var timer: Timer?
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadSettings()
    }
    
    func startTimer() {
        guard !isRunning else { return }
        
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.timerCompleted()
                }
            }
        }
    }
    
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        stopTimer()
        timeRemaining = TimeInterval(selectedMinutes * 60)
    }
    
    func setTime(minutes: Int) {
        selectedMinutes = minutes
        timeRemaining = TimeInterval(minutes * 60)
        saveSettings()
    }
    
    func setPomodoroTime(workMinutes: Int, shortBreakMinutes: Int, longBreakMinutes: Int) {
        pomodoroWorkTime = workMinutes
        pomodoroShortBreak = shortBreakMinutes
        pomodoroLongBreak = longBreakMinutes
        saveSettings()
    }
    
    func startPomodoroSession() {
        if isWorkSession {
            setTime(minutes: pomodoroWorkTime)
        } else {
            let breakTime = (currentPomodoroSession % 4 == 0 && currentPomodoroSession > 0) ? pomodoroLongBreak : pomodoroShortBreak
            setTime(minutes: breakTime)
        }
        startTimer()
    }
    
    private func timerCompleted() {
        stopTimer()
        
        // 通知を送信
        sendNotification()
        
        // システム音を再生
        NSSound.beep()
        
        // ポモドーロセッションの管理
        if isWorkSession {
            currentPomodoroSession += 1
        }
        isWorkSession.toggle()
    }
    
    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Vibe Timer"
        content.body = isWorkSession ? "作業時間が終了しました。休憩しましょう！" : "休憩時間が終了しました。作業を再開しましょう！"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func saveSettings() {
        userDefaults.set(selectedMinutes, forKey: "selectedMinutes")
        userDefaults.set(pomodoroWorkTime, forKey: "pomodoroWorkTime")
        userDefaults.set(pomodoroShortBreak, forKey: "pomodoroShortBreak")
        userDefaults.set(pomodoroLongBreak, forKey: "pomodoroLongBreak")
    }
    
    private func loadSettings() {
        selectedMinutes = userDefaults.object(forKey: "selectedMinutes") as? Int ?? 3
        pomodoroWorkTime = userDefaults.object(forKey: "pomodoroWorkTime") as? Int ?? 25
        pomodoroShortBreak = userDefaults.object(forKey: "pomodoroShortBreak") as? Int ?? 5
        pomodoroLongBreak = userDefaults.object(forKey: "pomodoroLongBreak") as? Int ?? 15
        timeRemaining = TimeInterval(selectedMinutes * 60)
    }
}
