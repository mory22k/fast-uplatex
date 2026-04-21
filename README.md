# fast-uplatex

日本語の論文やレポートを素早く書くための、`upLaTeX + dvipdfmx + latexmk` ベースのシンプルなテンプレートです。  
プリアンブルをキャッシュする `latexmkrc` を使って、繰り返しコンパイルを高速化しています。

## 特徴

- `upLaTeX` を使った日本語文書作成
- `dvipdfmx` による PDF 生成
- `latexmk` による自動ビルド
- キャッシュ済みプリアンブルによる高速コンパイル
- `main.bib` を使った参考文献管理
- VS Code から使いやすい最小構成

## 必要な環境

以下のコマンドが使える TeX 環境を想定しています。

- `uplatex`
- `dvipdfmx`
- `latexmk`
- `bibtex`

TeX Live を導入していれば、一般的にはこの構成で利用できます。

## 使い方

### 1. 原稿を書く

本文は [main.tex](main.tex) を編集します。  
参考文献は [main.bib](main.bib) に追加します。

### 2. コンパイルする

ターミナルで以下を実行します。

```bash
latexmk -time main.tex
```

PDF は `build/main.pdf` に出力されます。

不要ファイルを削除する場合:

```bash
latexmk -c main.tex
```

生成 PDF も含めて消す場合:

```bash
latexmk -C main.tex
```

## VS Code で使う

このリポジトリには [settings.json](.vscode/settings.json) が含まれており、`LaTeX Workshop` から `latexmk` を使ってビルドする想定です。

現在の設定では PDF ビューアーは `external` になっています。これは、VS Code の PDF ビューアー拡張や内蔵プレビューでは、日本語が正しく表示されない場合があるためです。日本語が文字化けしたり空白になったりする場合は、VS Code 内プレビューではなく外部 PDF ビューアーで確認してください。

## ファイル構成

- [main.tex](main.tex): 本文
- [main.bib](main.bib): 参考文献
- [latexmkrc](latexmkrc): ビルド設定と高速化用設定
- `.vscode/settings.json`: VS Code 向け設定
- `build/`: コンパイル生成物

## 補足

- 参考文献スタイルは `main.tex` 内の `\bibliographystyle{...}` で切り替えられます。
- 著者名や所属は `main.tex` の `\author` / `\affil` を編集してください。
- `latexmkrc` ではプリアンブル変更の有無を見て共通 `fmt` を再生成するため、初回より2回目以降のビルドが速くなります。

## 参考資料

- ただしい高速LaTeX論. <https://qiita.com/JyJyJcr/items/69769c88eea9d0dae152>. 2026年4月21日閲覧.
