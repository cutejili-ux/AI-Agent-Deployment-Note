# Phase 4 — 實機驗證及故障排除

**以下所有結果均為 PENDING。** GitHub 上的部署腳本不代表已在 Golden Gate 執行。

| ID | 測試 | PASS 標準 |
| --- | --- | --- |
| H00 | 私有備份與版本 | ~/.hermes/backups 存有 0600 備份；版本、磁碟與記憶體 baseline 紀錄完整 |
| H01 | Host workspace | ~/hermes_workspace 為真正目錄、0700、沒有 symlink，AGENTS.md 已載入 |
| H02 | Docker backend | terminal/file/execute_code 確實在 Linux Docker 執行，不是 macOS local fallback |
| H03 | 實際 mounts | Docker inspect 沒有 macOS Home、Photos、iCloud、SSH、Keychain 或 Docker socket；只有核准 workspace 作資料綁定 |
| H04 | Host 隔離 | 用無敏感測試路徑模擬讀寫容器外 Mac 路徑；全部失敗，無 host 新檔；Docker 終端 network=none |
| H05 | Workspace 檔案 | 在 /workspace 新建、讀取、修改測試檔，從 Mac 獨立比對 bytes，沒有誤報成功 |
| H06 | Search | Agent 真正使用 web_search；DDGS 返回有來源結果，沒有自行 curl / urllib；失敗兩次後停手 |
| H07 | Extract | web_extract 能從核准公開 URL 提取內容，或清楚回報 keyless 限流/失敗 |
| H08 | 雲端隔離 | 平常 local Ollama；Fallback list 仍空；工具容器無雲端 Key，Search 使用外部服務須明確告知 |
| H09 | 4B 溫度 0.2 | 10 項繁中/JSON、5 項工具、5 項搜尋，與舊 4B 對照正確率和時間；memory pressure 可接受 |
| H10 | 7B 試驗 | 只在授權下測試；確認真實 digest/量化、上下文、記憶體、工具準確率；32K catalog 與 64K 要求矛盾需註記 |
| H11 | Rollback | 原本 Hermes config 與 Sessions、model 原封不動恢復，舊 local 短聊天再次成功 |
| H12 | Git hygiene | Commit 無鑰匙、原始 Hermes log、macOS 個人路徑、私人 Sessions 或權限截圖 |

### 受控測試

- 檢查非敏感設定：hermes config get terminal.backend、hermes config get terminal.docker_network、hermes config get web.search_backend、hermes config check。
- 從 Hermes 工具執行 pwd; uname -s; ls -ld /workspace。uname -s 預期 Linux。不要只相信 agent 文字描述，另外由 operator 執行 docker ps 並 docker inspect 對應容器的 Mounts/NetworkMode/HostConfig.Memory。
- 使用自製無敏感 sentinel 測試絕對路徑失敗與工作目錄成功。**不要讓 agent 真正開啟私人文件作負面測試。**
- 從 Docker 工具中執行對 example.com 的 5 秒 timeout 連線測試，應失敗；在 Hermes 主程式的 web_search 中測試已知公共查詢，應能經 Search provider 返回結果。
- 兩次 provider 失敗必須立即停止；不可透過 shell 改用 curl 抓 Google Maps HTML。
- Dashboard/桌面 UI 如仍可直接使用 host 側檔案操作，不得視為完全 sandboxed；必須另做安全審核。
- Docker Desktop 自身加上 4B/7B 可能增加 swap；Memory Pressure warning/red、長時間未回覆即停止，不升級到 14B。

### STOP 與回復

發現 host backend 仍在執行工具、非預期 Mac Home mount、雲端 Key 進入容器環境、意外 API 費用、敏感存取提示或記憶體壓力持續上升：停止 POC，紀錄匿名化錯誤，執行 bash scripts/macos/harden.sh --rollback，重新啟動 Hermes。不要跑 docker system prune 或 Hermes full uninstall。

完成驗證後，把每項 PASS/FAIL/BLOCKED、版本、測試時間、tool trace、Docker 真實 mount/network、模型 tag/digest、Memory Pressure、swap、搜尋 Provider、root cause/修復寫入 docs/06-execution-log.md。這個文件不能提前填 PASS。
