#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
  tauri::Builder::default()
    .invoke_handler(tauri::generate_handler![start_timer])
    .setup(|app| {
      if cfg!(debug_assertions) {
        app.handle().plugin(
          tauri_plugin_log::Builder::default()
            .level(log::LevelFilter::Info)
            .build(),
        )?;
      }
      Ok(())
    })
    .run(tauri::generate_context!())
    .expect("error while running tauri application");
}

#[tauri::command]
pub async fn start_timer(seconds: u64) {
    use std::{thread, time};
    let mut remaining = seconds;
    while remaining > 0 {
        thread::sleep(time::Duration::from_secs(1));
        remaining -= 1;
        // ここでフロントエンドに残り時間を通知する処理を追加可能
    }
    // macOS標準通知音と通知
    #[cfg(target_os = "macos")]
    {
        use std::process::Command;
        let script = r#"display notification \"時間になりました！\" with title \"タイマー終了\" sound name \"Ping\""#;
        let _ = Command::new("osascript")
            .arg("-e")
            .arg(script)
            .output();
    }
}
