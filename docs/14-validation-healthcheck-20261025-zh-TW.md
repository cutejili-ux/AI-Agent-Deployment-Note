# 16 項驗收與本次健檢 — 手動重裝版本（2026-10-25）

**本輪未達整體驗收標準：4 PASS、6 FAIL、4 BLOCKED、2 SKIPPED。** 依原始 [04 — Validation](04-validation.md) 保留 T00–T15 全部案例與條件。原始矩陣以 Ollama + qwen3.5-4b-64k 為前提；目前為使用者自行重裝的 Hermes Desktop + 內建 llama.cpp + Qwen3.8-9B，不能把不同後端的檢查冒充成原案例 PASS。

- 實測起訖（Australia/Brisbane）：`2026-10-25T23:34:18+10:00` → `2026-10-25T23:40:37+10:00`。
- 使用者指定：**T13、T14 跳過；T11 只做一次受控 fallback。** 沒有移除或重裝任何原有 App／模型。
- 測試前建立私人資料 ZIP 備份，約 8.09 MB、439 entries、CRC 驗證通過，包含 config、dotenv、state.db，權限 0600。備份與原始 logs 留在本機，沒有上傳。
- 使用無 Telegram token 的 standalone 驗證 profile，並停用外部登入採用、輔助模型與自動復原循環；不修改正式 profile。測完已移除臨時 profile 與其複製憑證。
- [去識別機器可讀結果](../evidence/public/validation-2026-10-25-native.json)。

## T00–T15 結果

| 案例 | 結果 | 實測證據與限制 |
| --- | --- | --- |
| T00 硬體／系統 | PASS | arm64、Apple M6 / 16 GiB；macOS 27.0.1 (26A434)，本輪約 70 GiB 可用。baseline pressure 1、swap 1,676.25 MiB。 |
| T01 前置工具 | PASS | Git 2.54.0 (Apple Git-157)、Xcode developer directory 可用。 |
| T02 Ollama 安裝 | BLOCKED | 本次沒有 Ollama CLI；目前使用內建 llama.cpp。未為通過測試而另裝 Ollama，也沒有將替代後端標為原條件 PASS。 |
| T03 原定模型 | BLOCKED | 原定 qwen3.5-4b-64k Ollama tag 不存在。目前發現 Qwen3.8-9B Q6_K（7.040 GiB）與 14B Q4_K_M（8.529 GiB）檔案；實際 runtime context 98,304。 |
| T04 記憶體／執行 | BLOCKED | 原 Ollama run/ps 條件不可執行。替代的 native 短提示未成功，pressure 由 1 升 2、swap 約 3,250.81 MiB；沒有進行完整長視窗壓力測試。 |
| T05 Hermes 安裝檢查 | FAIL | v0.22.5 / commit bf0203a794a0 / Python 3.14.9；help、config check exit 0，但 doctor exit 1（可選工具金鑰未配置、npm audit findings），未滿足所有命令成功。這不表示 Hermes 完全無法啟動。 |
| T06 本機對話 | FAIL | 明確指定隔離 profile 的本機 custom endpoint / Qwen9B；等待 API 約 12.2 秒後 interrupted，程序 exit 130，未回 LOCAL_OK，沒有成功用量紀錄。記憶體同時警告；**中斷原因尚未證實**。 |
| T07 工具檔案操作 | FAIL | 只允許指定 scratch 測試檔，要求建立／讀取固定 bytes；90 秒外部上限後終止（harness exit 124），未產生符合內容的檔案。測試檔已確認清理。 |
| T08 無意外雲端用量 | FAIL | 正式全域預設為 Gemini 3.8 Flash；最近 Telegram session 亦選到 Gemini，先前 metadata 有實際雲端 tokens。正式預設不符合「日常 local-only」前提；本輪未另送日常 prompt 來製造額外雲端用量，也未核對 Google 儀表板。 |
| T09 手動 Gemini | FAIL | 隔離 profile 中做一次 synthetic GEMINI_OK 呼叫；約 76.7 秒外部上限終止，harness exit 124，未取得成功回覆與可關聯用量。不能把終止時的 KeyboardInterrupt 當成 provider HTTP 錯誤。 |
| T10 缺少金鑰 | PASS | 只清空測試 profile 的憑證；0.67 秒 exit 1，CLI 明確報 No usable credentials found for provider gemini 並列 GOOGLE_API_KEY / GEMINI_API_KEY，沒有替代供應商回覆。正式金鑰完全未改動。 |
| T11 受控 fallback | FAIL | 使用者授權一次。測試 profile 的 primary 指到已確認未監聽的 loopback port 9，fallback 僅 Gemini。約 91.7 秒外部上限後終止；沒有取得 FALLBACK_OK、成功 Gemini 用量或足夠切換證據。**不能因此直接斷言 fallback 功能有 bug。** 實際本機服務未停止，測完 fallback 已清空。 |
| T12 復原 | BLOCKED | 原 Ollama restart 前提不存在。本機出現警告後未再增加 native 推論負載，也未為測試重啟正式模型服務／Telegram。正式設定保留不等於通過「重啟後成功聊天」案例。 |
| T13 移除與保留資料 | SKIPPED | 使用者明確指定不測試；僅完成官方 dry-run 與私人備份，不沿用前次重裝的 PASS。 |
| T14 重新安裝 | SKIPPED | 使用者明確指定不測試，本輪沒有移除或重裝。 |
| T15 Git 去敏 | PASS | 已完成 staged 檔案白名單、diff 空白檢查、實際儲存金鑰 exact-match、常見 token／個人路徑／session ID 掃描；只發佈 5 份文件與去識別資料，不納入原始設定、logs、sessions、資料庫或備份。 |

**注意狀態定義：** BLOCKED 是原測試的後端／前置條件不成立；SKIPPED 是使用者指定略過。FAIL 是本輪沒有達到該案例驗收條件，不等於已確定根因或所有正常使用均會失敗。沒有套用歷史測試結果當作本輪執行證據。

## 納入本次快速健檢

1. **預設模型與日常路由有落差。** 實際全域預設為 Gemini 3.8 Flash；本機 Qwen session 成功紀錄與 Telegram Gemini session 並存。桌面切換單一聊天的模型，不代表 bot 與全域預設同步切換。
2. **記憶體風險。** Qwen3.8-9B Q6_K 檔案約 7 GiB、實際 context 98,304。初次健檢曾 pressure 2 / swap 5,324.75 MiB，後來恢復 pressure 1 / swap 2,076.25 MiB；本輪 baseline 亦正常，但本機測試後再次警告。數字包含其他 App，不把所有 swap 或中斷都歸因於模型。14B 檔案在磁碟上，不等於它當下也載入 RAM。
3. **Telegram 基本連線正常。** 官方唯讀 getMe 成功；getWebhookInfo 無 webhook、pending update 0、沒有 last_error。配對核准名單 1 位，allow_all_users=false；dotenv 沒填 allowed-users 不是直接暴露所有人，核准配對亦可授權。本輪沒有發送 bot 訊息或讀取 getUpdates。
4. **工具權限較寬。** terminal.backend=local，Telegram 使用 hermes-telegram 預設工具集，max_turns=500、session 並行未設上限。這是權限／資源配置風險，並非 token 錯誤；只改 cwd 也不代表作業系統沙盒。
5. **雲端與依賴異常。** 歷史近期 logs 有 Gemini 503、429、逾時，亦有較早成功雲端用量；這些與本輪 timeout 分開記錄。doctor 的缺金鑰項是可選工具，不代表 GOOGLE_API_KEY 一定無效；npm audit findings 仍待上游 lockfile 修正。
6. **兩份桌面啟動來源。** Applications 與 source checkout 內均有 Hermes.app，目前執行 source 內版本。可造成啟動／更新來源混淆，但沒有僅憑 Electron bundle 的 0.0.x 版本字串判定引擎版本錯誤。CLI 確認為 v0.22.5。
7. **模型清單限制。** 在已檢查的 Hermes GGUF 目錄與 session model metadata 未見 Llama3.2/Mistral；不排除它們曾被刪除或使用外部目錄，因此不宣稱它們從未安裝。

## 復原與資料保護

- 正式 config.yaml 與 .env 已和測試前私人備份逐 byte 比對，相同；沒有把其內容或雜湊公開。
- 原有 Telegram gateway 程序仍存在；沒有執行停止它的命令。臨時 profile 已清除；正式 fallback 原本與測完均為空。
- 一次測試 harness 的 gateway 安全核對原先只找 argv 的 profile 名稱而停止繼續；實際 standalone 程序透過 HERMES_HOME 啟動。後續改為核對 PID metadata 的專用 home，並排除正式 PID，才停止測試用 gateway。**這是測試工具防護的調整，不列為 Hermes 設定錯誤。**
- T10 最初文字比對漏認 No usable credentials found；覆核實際 CLI 輸出後改為 PASS。未重新製造一個假的通過結果。
- 本輪沒有修正正式設定、下載模型、測試全 96K 輸入、升級依賴或改動 Google 計費。私人證據是本機診斷資料，並未進 Git。
