# 第二階段：Gemini 手動呼叫（2026-10-24）

**目前結果：設定完成；成功推論驗證受 Google HTTP 503 阻擋。**

使用者已接受第一階段並授權推送、進入 Gemini 階段。已透過 Mac 本機隱藏輸入框儲存 Google AI Studio 金鑰；金鑰只留在 `~/.hermes/.env`（權限 0600）。GitHub 沒有金鑰或原始 session/log。

## 實測結果

| 項目 | 結果 |
| --- | --- |
| Google 模型清單 | HTTP 200；與本機 Hermes 選單交叉確認模型 |
| gemini-3.7-flash | 原生 API 回傳 503「需求過高」；120 秒外部時限後終止測試及內建復原 |
| gemini-3.8-flash | 明確手動換模型；限制重試後約 30 秒回傳相同 503，程序 exit 1 |
| Provider 路由 | Hermes 記錄證明使用 gemini 與 Google 原生 API host |
| 缺少金鑰測試 | 正確拒絕執行；後端能辨認缺少金鑰，CLI 錯誤文字仍過於籠統；金鑰已復原 |
| 回到一般本機對話 | 成功回覆 LOCAL_STILL_OK；metadata 確認 custom + loopback Ollama |
| 用量／費用 | 失敗 session 沒有成功 token/計費紀錄；不可據此宣稱 Google 費用為零，仍需核對 Google 儀表板 |

本次沒有啟用自動 fallback，也沒有變更 Google 計費方案。兩個 Flash 模型都遇到服務 503，因此停止繼續試模型；沒有將這項測試標為通過。

## 使用方式

平常沿用本機：

```sh
cd ~/Projects/hermes-poc-scratch
hermes chat --reasoning none
```

Google 服務恢復後，可明確執行一次無敏感內容的 Gemini 測試：

```sh
hermes chat --oneshot \
  --provider gemini \
  --base-url https://generativelanguage.googleapis.com/v1beta \
  --model gemini-3.8-flash \
  --reasoning none --max-turns 1 --run-budget 90 \
  --toolsets file \
  -q 'Answer with exactly GEMINI_OK. Do not use tools.'
```

此指令只覆寫該次呼叫；預設仍為 `qwen3.5-4b-64k`，endpoint `http://127.0.0.1:11434/v1`。模型可用清單日後會變動，若出現 unknown model，先重新查詢實際可用模型。

POC 設定已將 `agent.api_max_retries` 設為 1、`agent.auto_recovery_cycles` 設為 0，並將 Gemini request/stale timeout 設為 20/25 秒。這些限制可避免先前 503 後長時間復原循環；`--run-budget` 並非所有 in-flight API 工作的硬性 wall-clock 上限。設定前備份留在本機 `~/.hermes/config.yaml.pre-gemini-poc`。

成功回覆後，仍須核對原生 provider/model 記錄與 Google 用量儀表板，才能完成 G3。自動 fallback 是另一個需要明確批准的失敗實驗，本階段保持關閉。
