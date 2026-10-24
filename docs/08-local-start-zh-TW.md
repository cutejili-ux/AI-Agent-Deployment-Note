# 本機啟動與目前結果（2026-10-24）

本機已安裝 Hermes v0.22.5、Ollama 0.40.10，以及 Qwen3.5 4B 的 65,536 context 衍生模型。對話與服務重啟測試通過；檔案建立／讀取有實際執行，但模型漏掉指定換行，修正時又出現錯誤路徑與誤報完成。因此目前是 LIMITED PASS，不能視為完整可靠的自主 agent。

## 開始使用

開新的 Terminal（安裝程式已加入 PATH），或在現有 zsh 執行：

```sh
source ~/.zshrc
```

Ollama 目前已在本機運行。先檢查：

```sh
curl -fsS http://127.0.0.1:11434/api/tags
```

若重開機後尚未啟動、上面顯示無法連線，在一個 Terminal 執行並保持開啟：

```sh
OLLAMA_HOST=127.0.0.1:11434 OLLAMA_NO_CLOUD=1 ollama serve
```

若顯示 port 已被使用，先確認現有服務，不要再啟動第二份。這次沒有設定開機自動啟動。

另一個 Terminal 執行：

```sh
cd ~/Projects/hermes-poc-scratch
hermes chat --reasoning none
```

短測試：

```sh
hermes chat --oneshot --reasoning none --max-turns 3 -q '請用繁體中文打招呼。'
```

`--reasoning none` 與已完成的測試相同，減少這個小模型的推理延遲。模型名稱為 `qwen3.5-4b-64k`；本機 API 是 `http://127.0.0.1:11434/v1`。CLI 可能自動啟動僅在 loopback 運作的暫時內部 gateway；沒有設定 Telegram、Discord 或 launchd gateway。

## 設定與限制

- 設定：`~/.hermes/config.yaml`；原始安裝設定備份：`~/.hermes/config.yaml.pre-local-poc`。
- 本機工具只啟用 terminal / file。scratch cwd 是工作目錄設定，並非作業系統強制的檔案沙盒；請維持在無敏感資料的測試目錄使用。
- Gemini 金鑰已於第二階段存入本機；兩個 Flash 模型的推論皆回傳 Google HTTP 503，詳見 [Gemini 階段紀錄](09-gemini-stage-zh-TW.md)。預設仍是本機，雲端 fallback 關閉；外部登入採用、輔助標題生成、壓縮、內建記憶、遙測與背景 skill curator 維持停用。
- 64K 設定的短提示可運作，但第三階段長輸入測試因 macOS 記憶體壓力警告而停止；完整 64K 輸入穩定性尚未通過。測試完成卸載模型後 pressure level 1、swap 約 2.13 GiB。
- `hermes doctor` 發現 stable 版本的 npm 依賴漏洞，需追蹤上游 lockfile 修正；本次未修改供應商依賴。
- 任何模型宣稱的檔案修改，都要在檔案系統另行核對；這次測試已出現誤報成功。
- 本機階段已獲使用者接受並授權發佈實測文件、進入 Gemini 手動呼叫階段；上述測試限制仍保留。第三階段已完成保留資料的移除／重裝，詳見 [驗收紀錄](10-validation-reinstall-zh-TW.md)。

完整實測、版本、失敗與資源數據見 [06-execution-log.md](06-execution-log.md)。

第三階段另外通過單一相對檔名的建立／讀取／編輯測試，仍須人工核對修改。模型已從 RAM 卸載以釋放資源，下一次對話會重新載入；模型檔案仍保留。
