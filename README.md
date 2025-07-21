# Vibe Timer

macOS用のメニューバー常駐タイマーアプリケーションです。

## 特徴

- **Liquid Glass UI**: 半透明で美しいガラス効果のインターフェース
- **メニューバー常駐**: デスクトップを占有せず、メニューバーから簡単にアクセス
- **ポモドーロテクニック対応**: 作業と休憩のサイクルを管理
- **円形スライダー**: 直感的な時間設定UI
- **バックグラウンド動作**: 正確な時間計測とデスクトップ通知

## 機能

### 基本機能
- カウントダウンタイマー（最大60分）
- プリセット時間（3分、5分、10分）
- カスタム時間設定（円形スライダー）
- バックグラウンドでの正確な計時
- 設定の永続化

### ポモドーロテクニック
- 作業セッション（デフォルト25分）
- 短い休憩（デフォルト5分）
- 長い休憩（デフォルト15分）
- セッション進捗管理
- カスタマイズ可能な時間設定

### 通知
- デスクトップ通知
- システム音による音声通知
- 通知クリックでメニュー表示

## システム要件

- macOS 14.0以降
- Xcode 15.0以降（開発時）

## ビルド方法

### 前提条件
1. Xcodeがインストールされていること
2. Apple Developer アカウント（配布時）

### ビルド手順
1. プロジェクトをクローンまたはダウンロード
```bash
git clone [repository-url]
cd vibe-timer
```

2. Xcodeでプロジェクトを開く
```bash
open VibeTimer.xcodeproj
```

3. ビルドターゲットを設定
   - Product > Scheme > Edit Scheme
   - Run > Info > Build Configuration を "Release" に設定

4. ビルド実行
   - Product > Build (⌘+B)
   - Product > Archive（配布用）

### コマンドラインビルド
```bash
# プロジェクトディレクトリで実行
xcodebuild -project VibeTimer.xcodeproj -scheme VibeTimer -configuration Release -derivedDataPath build
```

## 配布用パッケージの作成

### DMGファイルの作成
```bash
# ビルド後のアプリを取得
cp -R build/Build/Products/Release/VibeTimer.app ./

# DMGを作成
hdiutil create -volname "Vibe Timer" -srcfolder VibeTimer.app -ov -format UDZO VibeTimer.dmg
```

## 開発

### プロジェクト構造
```
VibeTimer/
├── VibeTimerApp.swift      # メインアプリケーション
├── ContentView.swift       # メインUI
├── TimerManager.swift      # タイマー管理
├── Views.swift            # UIコンポーネント
└── VibeTimer.entitlements # アプリの権限設定
```

### 主要クラス
- **VibeTimerApp**: メインアプリケーションとメニューバー管理
- **TimerManager**: タイマーの状態管理とポモドーロ機能
- **ContentView**: メインのユーザーインターフェース
- **LiquidGlassBackground**: Liquid Glass UIの実装

## ライセンス

[ライセンス情報を記載]

## 貢献

プルリクエストやイシューの報告を歓迎します。

## サポート

問題が発生した場合は、GitHubのIssuesページにて報告してください。