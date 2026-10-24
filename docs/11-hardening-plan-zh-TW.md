# Phase 4 — Golden Gate 安全、搜尋及模型優化

**2026-10-24。狀態：已建立腳本與文件，尚未在 Golden Gate 實際套用。** 保留 2026-10-24 Phase 1–3 所記錄的 LIMITED PASS、Hermes Gemini 503/逾時、64K 記憶體限制及 npm audit 警告。不能把 GitHub Commit 當作實機驗證通過。

## 建議架構

- macOS 原生：Hermes CLI / Desktop，Ollama 0.40.10，Apple GPU (Metal / MLX)，原有會話和 key。
- Docker Desktop (Apple Silicon)：只承載 Hermes 的 terminal、file 和 execute_code 工具；容器限制 1536 MB RAM、2 CPU、network=none，且不轉送主機環境 API Keys。
- ~/hermes_workspace（實體目錄、權限 0700）：唯一明確的 Mac 主機資料綁定 /workspace:rw。不掛載 /Users 整棵樹、iCloud、Photos、SSH、Keychain、Docker socket。Docker container 的 Linux 系統檔及 Hermes 自己的 sandbox state 仍存在，不可宣稱容器內只能讀取 /workspace。
- Hermes host-side web_search／web_extract：搜尋詞仍會送到搜尋服務。Docker network=none 僅約束 terminal/code 工具，不會阻止主程式查詢原生 Web Search 或雲端 LLM。
- Cloud：OpenAI、Anthropic、Gemini 可日後個別授權；預設本地 Ollama，Gemini 原有故障另案排查，自動 fallback 保持關閉。

為何不把 Ollama 也放進 Docker？官方說 Docker Desktop on Mac 不支援 Apple GPU passthrough。原生 macOS 保持 GPU 推論效能。為何不只改 terminal.cwd？工作目錄或 System Prompt 都不是硬隔離；先前 CLI 在 host 帳號執行已能觸及本機可讀路徑。Docker 工具 backend 才限制對 Mac host 的掛載範圍。惟 Hermes 主程式、Desktop host-side 檔案瀏覽/其他插件可能仍擁有 host 帳號權限，不能保證 macOS 永不彈出權限要求。

## Golden Gate 執行順序

1. 停止正在運行的 Hermes 聊天與 temporary gateway；記錄原先版本、model digest、空間、macOS Memory Pressure，確認原有 15 Sessions 和 Gemini Key 正常保留。不要複製 ~/.hermes/.env 到 Repository。
2. 安裝官方 Docker Desktop for Apple Silicon 並啟動 Docker engine。只批准必需的 workspace sharing；確認 Docker Desktop 授權/虛擬機 RAM 和磁碟空間足夠。這台機器只有 16GB RAM，Docker VM 也會消耗記憶體。
3. 在 repository 根目錄執行：bash scripts/macos/harden.sh --check。確認 workspace 不是 symlink，Docker 可以啟動。
4. 明確確認後執行：bash scripts/macos/harden.sh --apply。腳本先在 ~/.hermes/backups 建立 0600 私有 config 備份，再建立 workspace/AGENTS.md，設定 backend=docker、只掛載 workspace、Docker network off、manual approvals、Web DDGS search + Tavily extract。它不修改 model.default、不安裝 14B、不清除 sessions、不動現有 key。
5. 重新啟動 Hermes。用 hermes config check 和單一 hermes config get 讀取非敏感鍵；從 Docker inspect 驗證真正 Mounts、NetworkMode、Memory。**如果工具仍在 macOS host 跑，停止並 rollback。**
6. 以 hermes tools 確認 web toolset 可用，以及在 Hermes 的 Python venv 安裝 ddgs optional package（非 Docker image）。DDGS 無 API Key，但有限流/可用性風險。若不穩，再用已核准 Brave Search API (BRAVE_SEARCH_API_KEY) 作 web.search_backend；Tavily 可作 web_extract，keyless 使用可能受限。
7. 從 macOS 執行：cd ~/hermes_workspace；hermes chat --toolsets "web,file,terminal"。請先從 /context 或工具訊息確認 AGENTS.md 是否載入，並用工具驗證容器的 uname -s 是 Linux、cwd=/workspace。
8. 依 docs/12-hardening-validation-zh-TW.md 執行負面讀寫測試、網路阻斷測試、web_search/web_extract 測試、Search 兩次失敗停手測試。只測試自行建立的無敏感資料；絕不請工具真正讀取 Photos 或秘密。
9. 執行 bash scripts/macos/model-trials.sh --plan。可先用 --build-4b 製作同權重、temperature=0.2 的 qwen3.5-4b-t02，測試繁體中文、氣象代碼 JSON、Tool Calling、搜尋正確性。原有 4B 保留作基準，不自動切預設。
10. 7B 僅在 4B 不滿足、Docker 系統記憶體允許且 operator 明確選擇的情況執行 --build-7b；實際啟動時監測 Activity Monitor、swap、時間、上下文，失敗即停止。14B 不自動安裝。

### 模型 Context 衝突

Ollama qwen2.5:7b / qwen2.5:14b 預設 catalog 標示 32K；Hermes 的文件要求最低 64K。Modelfile 中硬設 num_ctx=65536 並不證明模型真的能穩定處理 64K，也不保證模型超出原版 window 後的正確率。之前原有 4B 的 8K 測試已造成記憶體壓力警告。先測試 4B 的 temperature 0.2，然後才是 7B；不要聲稱 7B/14B 一定改善工具呼叫或繁中品質。

### Web Search 和 System Prompt

Hermes v0.22.5 的原生 web_search、web_extract 已提供 DDGS、Brave、Tavily 等 Provider，初期不用外加 MCP。~/hermes_workspace/AGENTS.md 規定：禁止直接 curl/urllib/wget 硬爬 Google Search 和 Maps HTML、優先 web_search、最多失敗兩次、回報原因，不推測未驗證 JSON/API 代碼。Jina Reader 的 r.jina.ai 沒有被當作已核實的 Hermes 原生 backend；目前先使用原生 web_extract。如要 Headless Browser/MCP，必須額外評估權限、RAM、信任網域與資源。

### 雲端 API

config/cloud-keys.env.example 只有空欄位，不可以覆蓋現有 ~/.hermes/.env；真實 key 留在本機、權限 0600，透過 hermes model 個別登入/設定。不要自動開 Gemini fallback；先解決先前 503 與 Timeout，並以 Google 用量紀錄核對實際費用。Docker terminal.docker_forward_env=[] 可以避免主機已設定的雲端金鑰任意傳給工具容器；務必驗證沒有其他工具、技能或環境繞過此限制。

### Rollback

在原 repo 路徑執行 bash scripts/macos/harden.sh --rollback；腳本僅還原最近一次套用前的 config.yaml，保留 workspace、Docker、models、API keys、Sessions。之後重新啟動 Hermes，核對原本 provider、fallback、工具 backend。容器/映像不會被粗暴清理；只有人工核對所有者和依賴後才能手動清理。

### 官方依據

- https://hermes-agent.nousresearch.com/docs/user-guide/configuration
- https://hermes-agent.nousresearch.com/docs/user-guide/docker
- https://hermes-agent.nousresearch.com/docs/user-guide/security
- https://hermes-agent.nousresearch.com/docs/user-guide/features/web-search
- https://hermes-agent.nousresearch.com/docs/user-guide/features/context-files
- https://ollama.com/library/qwen2.5
- https://ollama.com/blog/ollama-is-now-available-as-an-official-docker-image
