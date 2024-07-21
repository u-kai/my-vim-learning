## Ctrl + r がおそらくレジスタに対する処理

- Ctrl + r + register で挿入モードでヤンク
- Ctrl + r + = で挿入モードで計算に入る

## 移動に関するチップス

- m{a-zA-Z}コマンドは現在のカーソル位置にマークする

  - \`{mark}でマーク位置に戻ることができる
  - mm からの\`m がよっぽどのことがない限り良い
  - マークが小文字の場合はファイルローカル
  - マークが大文字の場合はグローバル

- 便利な自動マーク

  - ''
    - 現在のファイルで直前におこわれていたジャンプ以前にいた場所
  - '.直前に変更があった場所

- %はカッコなどの対応する場所に移動
- [count]G で指定した行番号の行にジャンプ
- H
  - 画面の先頭にジャンプ
- M
  - 画面の中央にジャンプ
- L
  - 画面の末尾にジャンプ
- gf
  - カーソル位置に記述されているファイル名にジャンプ
- Ctrl + o で前のファイルに戻る
- Ctrl + i で次のファイルに戻る
  - 次とか前とかは jumps で表示されるジャンプリストのもの

## コマンドライン

- :t(:copy のエイリアス)で[range]t {address}で address で指定した場所に range で指定したものをコピー意する
  - address は.を利用すると現在位置にコピーしてくれる