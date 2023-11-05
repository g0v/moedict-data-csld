# 支語檢查器

這是將「中華語文知識庫」的 Word、Excel 資料處理為機器比較容易再利用的 CSV、TSV 及 JSON 格式。原始 .xlsx、.docx 檔的著作權為中華文化總會所有。轉換格式、重新編排的編輯著作權（如果有的話）由 唐鳳 以 CC0 釋出。

原始資料授權聲明如下：

《中華大辭典》由中華文化總會以 CC BY-NC-ND 4.0 授權予萌典專案使用。

如需洽談內容授權或其他合作事宜，請提供聯絡資訊及希望的授權或合作模式，寄至 <service@chinese-linguipedia.org> 電子信箱。

## install

```shell
poetry install # install python dependencies
cd ui && yarn install # install frontend dependencies
```

## local run

```shell
make runs # run backend server
cd ui && yarn dev # run frontend server
```

see <http://localhost:3000/checker>
