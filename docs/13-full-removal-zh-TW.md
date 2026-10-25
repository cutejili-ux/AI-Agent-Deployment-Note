# 完整移除 Hermes 與 Ollama（2026-10-25）

**結果：本機程式與專用資料完整移除，驗證通過。**

使用者明確要求「根據已記錄的安裝文件，把 Hermes、Ollama 全部移除」。本次採完整刪除模式，包含本機設定、金鑰、sessions、模型及私人備份。既有 GitHub 文件與本機文件 repository 保留。

## 執行紀錄

- 依 `docs/05-troubleshooting-rollback.md`、既有安裝／重裝紀錄及 [Ollama 官方 macOS 移除說明](https://docs.ollama.com/macos#uninstall)核對實際路徑。
- 先執行 `hermes uninstall --full --dry-run`；gateway 已沒有運作中的程序。
- 停止已辨識的 Ollama App 與其 Squirrel 更新程序；當時沒有 11434 listener，模型 CLI 查詢也未能啟動服務，因此未為了逐一移除模型而另外啟動服務。
- 執行官方 `hermes uninstall --full --yes`，exit 0。移除 source checkout、CLI wrapper、Hermes 管理的工具/runtime store、`~/.hermes` 全部內容、Electron 桌面資料與專用快取；其中包含本機 Gemini 金鑰、所有 sessions、logs 及先前私人 ZIP 備份。
- 另外清除官方移除後殘留的 Hermes macOS preferences domain `com.nousresearch.hermes`。
- 刪除 `/Applications/Ollama.app`、`~/.ollama`（含全部模型與設定）、`~/Library/Application Support/Ollama`、`~/Library/Caches/ollama`，清理 Ollama 專用偏好設定與其他官方已知資料路徑。
- 刪除使用者 CLI symlink `~/.local/bin/ollama`。另發現當天 App 建立的 root-owned `/usr/local/bin/ollama`；確認 target 為同一個 Ollama App 後，透過 macOS 原生管理員授權移除此單一 symlink。管理員密碼沒有進入對話或執行紀錄。
- 清除已空白的 `~/Projects/hermes-poc-scratch`。
- 先前 `/tmp/hermes-poc-*` 安裝／驗證暫存檔在本次檢查時已不存在；本次移除用的暫時 log 於結果整理後清除。
- 保留共用 Git、Xcode/Apple 開發工具、Homebrew 與非應用專用的共用語言/runtime 快取；沒有執行全域 cache purge 或 Docker prune。Phase 4 sandbox/model-trial 文件仍是歷史未部署規劃，沒有執行其部署腳本。

此處「刪除金鑰」指本機 dotenv 與其備份；未操作 Google 帳戶的遠端 API key 撤銷或計費設定。

## 最終驗證（Australia/Brisbane，約 14:38）

| 檢查 | 結果 |
| --- | --- |
| Hermes/Ollama App、CLI 及 root 系統捷徑 | 不存在 |
| `~/.hermes`、`~/.ollama` | 不存在 |
| Hermes/Ollama 桌面資料、專用 caches/preferences | 掃描無殘留 |
| LaunchAgents / LaunchDaemons / PrivilegedHelperTools | 掃描無 Hermes/Ollama 殘留 |
| 全新 `zsh -lic` 中的 `command -v hermes`、`command -v ollama` | 皆找不到 |
| 相關 App／服務程序 | 無 |
| TCP 127.0.0.1:11434 | 無 listener |
| 空白 POC scratch 目錄 | 已移除 |

移除前資料目錄約 Hermes 3.7 GB、Ollama 模型 3.7 GB、Ollama App 664 MB。`df -k /` 的可用空間由 89,234,860 KiB 增至 97,723,008 KiB，觀察到增加約 **8.1 GiB**；系統其他工作可能造成小幅變動，並非逐檔精確回收計算。

## 現況

此 Mac 已無 Hermes/Ollama 安裝。其餘文件中的啟動指令、金鑰存在與備份保留描述均為之前各階段的歷史紀錄，不能視為目前狀態。重新部署需要重新安裝；本次沒有重裝或設定新的服務。
