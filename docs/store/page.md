# 投稿ページの素材（itch.io / PLiCy 共通）

画像: `docs/store/images/`（`tools/screenshot.gd` の title / showcase / starbook / secretbook モードで作り直せる。3つめの引数で ja / en）
- cover.png … 表紙 630×500（itch.io の Cover image）。showcase_ja.png を縮めてタイトルを重ねたもの
- title・showcase・starbook・secretbook（_ja / _en）… スクショ 720×1280。日本語のサイト（PLiCy）は _ja、itch.io は _en を先に、_ja も何枚か

投稿用 zip: `powershell -File tools\package_store.ps1` → `build\kuma-kitchen-web.zip`

## 基本情報

- タイトル: くま紳士のキッチン / The Gentleman Bear's Kitchen
- 種類: HTML（ブラウザで遊ぶ）／ 縦画面 720×1280（itch.io の埋め込みは 450×800、フルスクリーンボタンあり）
- 対応: PC・スマホのブラウザ（タップ／マウス）
- 言語: 日本語・English（タイトル画面で切り替え。はじめはブラウザの言語）
- 価格: 無料
- ジャンル: パズル（組み合わせ・レシピ集め）

## 紹介文（コピペ用）

PLiCy は「日本語」の枠だけ、itch.io は「English」と「日本語」を続けて貼る（海外向けなので英語を先に）。

### 日本語

```text
くま紳士ららすけは、お料理上手をめざして今日もお料理修行。
材料を鍋に入れて「煮る」と、何かができあがる……。
組み合わせを試して、レシピ帳をいっぱいにしよう！

・カブ・トマト・イチゴ・ミルクから始まり、料理を覚えるほど新しい材料や大きな鍋が手に入ります
・材料は使うと減り、「次の日」で少し届きます。何日でレシピ帳をうめられるか挑戦！
・失敗が続くと、夜のうちに妖精さんがレシピ帳にヒントを書いてくれる……？
・覚えた料理に、もうひと工夫の「隠し味★」
・どこにも書いていない「ひみつのレシピ」も……

全32品＋ひみつのレシピ。1回 15〜20分くらい。ベスト記録はブラウザに保存されます。
日本語・English に対応（タイトル画面で切り替え）。

【AI の利用について】
このゲームは、ららすけ（企画・ゲームデザイン）と AI（Anthropic の Claude）がいっしょに作りました。
ルールやアイデアはららすけが考え、プログラム・絵（コードで描いた図形）・効果音（コードで作った音）・ゲーム内の文章（日本語・英語）は AI が作っています。
```

### English

```text
Lalasuke, the gentleman bear, is training to become a fine cook.
Put ingredients in the pot, tap "Cook", and something comes out...
Try combinations and fill up the recipe book!

・Start with turnips, tomatoes, strawberries and milk. Learn more dishes to unlock new ingredients and a bigger pot
・Ingredients run out as you use them, and a few more arrive each new day. How fast can you complete the book?
・Failing a lot? A fairy might leave hints in your recipe book overnight...
・Add a "secret ingredient ★" to dishes you already know
・And there are secret recipes that aren't written anywhere...

32 dishes plus secret recipes. About 15-20 minutes per run. Best records are saved in your browser.
Playable in English and Japanese (switch on the title screen).

[About AI use]
Made together by lalasuke (concept & game design) and an AI, Anthropic's Claude.
lalasuke came up with the rules and ideas; the AI wrote the code, the art (shapes drawn in code), the sound effects (generated in code) and the in-game text (Japanese and English).
```

### キャッチコピー・短い説明

```text
材料を組み合わせて、レシピ帳をうめる料理ゲーム / Mix ingredients and fill your recipe book
```

### 操作説明（PLiCy の「操作説明」欄）

```text
棚の材料をタップ（クリック）すると鍋に入ります。鍋をタップすると1つ戻します。
2つ（あとで3つ）入れたら「煮る」で料理。材料がなくなったら「次の日」。
```

## itch.io の設定メモ

- Kind of project: HTML ／ zip をアップして「This file will be played in the browser」にチェック
- Embed options: Viewport 450×800（縦）／ Mobile friendly にチェック（Orientation: Portrait）／ Fullscreen button にチェック
- SharedArrayBuffer support: チェック不要（スレッドなしの書き出し）
- Genre: Puzzle ／ Tags: cooking, cozy, casual, cute, short, puzzle
- **AI generation disclosure: 「Yes」→ 使ったもの: Code・Graphics・Sound・Text**
- Language: English, Japanese
- Visibility: 最初は Draft（下書き）→ 動作確認してから Public

## タグ（PLiCy 向け・日本語）
料理, パズル, 組み合わせ, ほのぼの, 短編, スマホ対応, AI
