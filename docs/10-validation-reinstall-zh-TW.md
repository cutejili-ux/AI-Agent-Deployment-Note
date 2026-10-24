# 第三階段：驗收與保留資料重裝（2026-10-24）

**結果：保留資料重裝、短任務檔案操作通過；完整長 context 與 Hermes Gemini 呼叫仍未通過。**

## 已通過

- 使用單一相對檔名，在 scratch 目錄建立並讀取 `STEP3_FILE_OK`，獨立檢查確為 13 bytes、沒有結尾換行。耗時 11 秒。
- 接著將內容替換為 `STEP3_EDIT_OK` 並讀回，獨立 bytes 比對通過。耗時 8 秒。測試後只清除該測試檔。
- 建立私人完整資料備份，約 1.94 MiB、384 個項目；確認包含 config、dotenv、state.db、SOUL.md，ZIP CRC 完整，權限 0600。備份保留於本機 `~/.hermes/backups/`，包含金鑰，不上傳 GitHub。
- 確認程式碼無未提交變更、完成移除 dry-run 後，執行官方 `hermes uninstall --yes` 預設保留資料模式。沒有使用 `--full` 或 `--data`。
- 實際確認程式碼與 launcher 被移除，設定／金鑰 bytes 完全相同，原有 15 個 sessions 與 Ollama CLI 保留。
- 從官方 `v0.22.5` shallow checkout 重新執行最小安裝，仍跳過 setup、browser、computer-use。移除至重裝完成約 115.65 秒，所有命令 exit 0。
- 重裝後 commit 仍為 `bf0203a794a07aac3ff764972ab9087baa4e4f4e`，config 與 dotenv bytes 完全保留，原有 sessions 全數存在。再次套用 curator pause。
- config check 通過；本機回覆 `REINSTALL_LOCAL_OK`，耗時 6 秒。metadata 確認 custom provider、`http://127.0.0.1:11434/v1`、4,863 input / 4 output tokens。

這證明同一台 Mac 上保留資料的移除／重裝可重現，沒有證明清空所有資料或全新硬體安裝。先前工具路徑／換行修正失敗仍保留；本次較受限的短任務成功不等於普遍可靠。

## 長 context 測試：安全門檻停止

模型與 Hermes 的 context 設定全程維持 65,536；沒有偷偷降低 context。

| 測試 | 實際觀察 |
| --- | --- |
| 起始 | 模型未載入；macOS pressure level 1，swap 1,034.44 MiB |
| 約 8K 合成輸入 | 實際 prompt_eval_count 8,169，回覆 CONTEXT_OK，7.386 秒；GPU 模型約 4.33 GB |
| 8K 完成時 | pressure level 升至 2（警告），swap 仍為 1,034.44 MiB |
| 32K 目標請求 | 12 秒監測時仍為 pressure level 2，swap 1,379.19 MiB；觸發停止門檻並要求卸載模型 |
| 64K 目標 | 未執行；不能宣稱通過 |
| 後續 | 壓力恢復 level 1；另一觀察點 swap 曾為 2,365.50 MiB。測試結束卸載模型後，level 1、swap 2,181.44 MiB |

32K 請求沒有取得完整的 token 結果，不能當作成功完成。停止後的 swap 數字也包含其他應用程式，不能全部歸因於模型。**G1 的長輸入穩定性目前 BLOCKED**；短提示可運作，並不代表能安全持續使用完整 64K 輸入。

## Gemini 排查：不能只歸因於整體服務中斷

| 測試 | 結果 |
| --- | --- |
| Hermes 3.8 Flash 重測 | HTTP 503，約 25.23 秒，exit 1 |
| 最小 Google 原生 HTTP 請求 | HTTP 200，11.24 秒；8 prompt、3 visible output、57 thought、68 total tokens。未符合要求的精確回覆，因此僅證明這個最小請求可執行 |
| Hermes 非串流模式 | 逾時，約 47.17 秒，exit 1；測試後原 config 已逐 byte 還原 |
| Hermes 3.1 Flash Lite Preview | 清單中已確認可用；串流讀取逾時，約 22.78 秒，exit 1 |

相同時段有最小請求 HTTP 200，所以先前的 503 不足以證明整個 Google 服務中斷。Hermes 的實際 payload、工具／system context、串流方式、輸出 budget 都與最小請求不同，**根因尚未確定**。沒有修改供應商程式碼，也沒有啟用自動 fallback。

成功的最小請求提供了 API token usage；Google 儀表板／實際帳單仍未核對。沒有成功的 Hermes Gemini 回覆，因此 G3 不標為 PASS。

## 最終狀態

Hermes 已重裝可用，預設仍是本機 Qwen3.5 4B；Gemini 金鑰保留於本機，fallback 清單空白。測試用內部 gateway 已停止、模型已從 RAM 卸載，Ollama loopback API 仍運作，下一次本機對話會重新載入模型。沒有啟用開機自動服務。

日常啟動仍使用 [本機指南](08-local-start-zh-TW.md)。已知 npm audit 警告不因重裝相同 lockfile 而修復；本次未宣稱修好。
