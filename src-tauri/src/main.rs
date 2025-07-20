// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use tauri::{
    CustomMenuItem, Manager, menu::{Menu, MenuItemBuilder},
};
use tauri_plugin_notification::NotificationExt;
use std::sync::Arc;
use tokio::sync::Mutex;
use std::time::Duration;

#[derive(Default)]
struct TimerState {
    remaining_time: u64,  // 残り時間（秒）
    is_running: bool,     // タイマーが動作中かどうか
}

fn create_menu() -> Menu {
    let quit = MenuItemBuilder::new("quit").title("終了").build();
    let start = MenuItemBuilder::new("start").title("開始").build();
    let stop = MenuItemBuilder::new("stop").title("停止").build();
    let three_min = MenuItemBuilder::new("three_min").title("3分").build();
    let five_min = MenuItemBuilder::new("five_min").title("5分").build();
    let ten_min = MenuItemBuilder::new("ten_min").title("10分").build();

    Menu::new()
        .add_item(start)
        .add_item(stop)
        .add_separator()
        .add_item(three_min)
        .add_item(five_min)
        .add_item(ten_min)
        .add_separator()
        .add_item(quit)
}

#[tauri::command]
async fn start_timer(
    app_handle: tauri::AppHandle,
    timer_state: tauri::State<'_, Arc<Mutex<TimerState>>>,
) {
    let mut state = timer_state.lock().await;
    if state.remaining_time == 0 {
        state.remaining_time = 180; // デフォルト3分
    }
    state.is_running = true;
    drop(state);

    let timer_state_clone = Arc::clone(&timer_state);
    tauri::async_runtime::spawn(async move {
        loop {
            {
                let mut state = timer_state_clone.lock().await;
                if !state.is_running || state.remaining_time == 0 {
                    if state.remaining_time == 0 {
                        app_handle
                            .notification()
                            .body("タイマーが終了しました")
                            .show()
                            .unwrap();
                    }
                    break;
                }
                state.remaining_time -= 1;
                let remaining = state.remaining_time;
                drop(state);

                // メニューバーのタイトルを更新
                let minutes = remaining / 60;
                let seconds = remaining % 60;
                app_handle
                    .tray_handle()
                    .set_title(&format!("{:02}:{:02}", minutes, seconds))
                    .unwrap();
            }
            tokio::time::sleep(Duration::from_secs(1)).await;
        }
    });
}

fn main() {
    let timer_state = Arc::new(Mutex::new(TimerState::default()));

    tauri::Builder::default()
        .plugin(tauri_plugin_notification::init())
        .manage(timer_state.clone())
        .menu(create_menu())
        .on_menu_event(move |event| {
            match event.id().as_str() {
                "quit" => {
                    std::process::exit(0);
                }
                "start" => {
                    tauri::async_runtime::block_on(start_timer(
                        event.app_handle(),
                        event.app_handle().state::<Arc<Mutex<TimerState>>>(),
                    ));
                }
                "stop" => {
                    let timer_state = event.app_handle().state::<Arc<Mutex<TimerState>>>();
                    let mut state = tauri::async_runtime::block_on(timer_state.lock());
                    state.is_running = false;
                }
                "three_min" => {
                    let timer_state = event.app_handle().state::<Arc<Mutex<TimerState>>>();
                    let mut state = tauri::async_runtime::block_on(timer_state.lock());
                    state.remaining_time = 180;
                }
                "five_min" => {
                    let timer_state = event.app_handle().state::<Arc<Mutex<TimerState>>>();
                    let mut state = tauri::async_runtime::block_on(timer_state.lock());
                    state.remaining_time = 300;
                }
                "ten_min" => {
                    let timer_state = event.app_handle().state::<Arc<Mutex<TimerState>>>();
                    let mut state = tauri::async_runtime::block_on(timer_state.lock());
                    state.remaining_time = 600;
                }
                _ => {}
            }
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
