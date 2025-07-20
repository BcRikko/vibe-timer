#[cfg_attr(mobile, tauri::mobile_entry_point)]

#[tauri::command]
fn show_native_notification() {
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

pub fn run() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![show_native_notification])
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


