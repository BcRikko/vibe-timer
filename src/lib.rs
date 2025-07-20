use tauri::Manager;

#[tauri::command]
fn show_native_notification() {
    #[cfg(target_os = "macos")]
    {
        use std::process::Command;
        let script = r#"display notification \"時間になりました！\" with title \"タイマー終了\" sound name \"Ping\""#;
        let _ = Command::new("osascript").arg("-e").arg(script).output();
    }
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![show_native_notification])
        .setup(move |app| {
            let window = app.get_window("main").unwrap();
            window.show().unwrap();
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");

    tauri::Builder::default()
        .system_tray(system_tray)
        .on_system_tray_event(|app, event| {
            if let SystemTrayEvent::MenuItemClick { id, .. } = event {
                match id.as_str() {
                    "show" => {
                        if let Some(window) = app.get_window("main") {
                            #[cfg(target_os = "macos")]
                            {
                                window
                                    .set_position(Position::Logical(LogicalPosition::new(
                                        0.0,
                                        22.0, // macOSのメニューバーの高さを考慮
                                    )))
                                    .ok();
                            }
                            window.show().ok();
                        }
                    }
                    "quit" => {
                        std::process::exit(0);
                    }
                    _ => {}
                }
            }
        })
        .invoke_handler(tauri::generate_handler![show_native_notification])
        .setup(|app| {
            if cfg!(debug_assertions) {
                app.handle().plugin(
                    tauri_plugin_log::Builder::default()
                        .level(log::LevelFilter::Info)
                        .build(),
                )?;
            }

            // 初回起動時のウィンドウ位置を設定
            if let Some(window) = app.get_window("main") {
                #[cfg(target_os = "macos")]
                {
                    window
                        .set_position(Position::Logical(LogicalPosition::new(0.0, 22.0)))
                        .ok();
                }
            }
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
