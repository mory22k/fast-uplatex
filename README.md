# fast-uplatex

**⚠️注意⚠️**
VS Code の PDF Viewer 拡張や内蔵プレビューでは、日本語が正しく表示されない場合があります。日本語が文字化けしたり空白になったりする場合は、VS Code 内プレビューではなく、Adobe Acrobat Reader などの外部アプリで確認してください。

日本語の論文やレポートを素早く書くための、`upLaTeX + dvipdfmx + latexmk` ベースのシンプルなテンプレートです。  
プリアンブルをキャッシュする `latexmkrc` を使って、繰り返しコンパイルを高速化しています。

## 特徴

- `upLaTeX` を使った日本語文書作成
- `dvipdfmx` による PDF 生成
- `latexmk` による自動ビルド
- キャッシュ済みプリアンブルによる高速コンパイル (プリアンブル変更の有無を見て共通 `fmt` を生成するため、初回より2回目以降のビルドが速くなります)
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

本文は [main.tex](main.tex) を編集します。参考文献は [main.bib](main.bib) に追加します。

### 2. コンパイルする

ターミナルで以下を実行します。

```bash
latexmk main.tex
```

PDF は `main.tex` と同じ場所の `main.pdf` に出力されます。ビルド途中生成物は `build/` に出力されます。

- latexmkの機能として、`pvc` オプションをつけると、ファイルの変更を監視して自動で再コンパイルします。

    ```bash
    latexmk -pvc main.tex
    ```

    **⚠️注意⚠️** `pvc` オプションをつけたままプリアンブルを変更しても、キャッシュの再生成が行われないため、変更が適用されません。プリアンブルを変更した際は `pvc` を外してビルドしてください。

     ```bash
    latexmk main.tex
    ```

- 不要ファイルを削除する場合

    ```bash
    latexmk -c main.tex
    ```

- 生成 PDF も含めて消す場合

    ```bash
    latexmk -C main.tex
    ```

## VS Code で使う場合の注意点

Visual Studio Code で使う場合、 `LaTeX Workshop` は使用しないことをおすすめします。`LaTeX Workshop` を使用せずにターミナルから直接 `latexmk` を呼び出すこともできますし、そちらのほうが意図しないエラーが生じた際の強制停止がやりやすいためです。本リポジトリはコンパイル方法の特性上、時々エラーが生じますが、LaTeX Workshop を使用している場合、強制停止にやや煩雑な操作が必要となります。

一方で、`LaTeX Workshop` は便利でもあります。`LaTeX Workshop` に関するいくつかの問題点を受け入れたうえで利用することも想定し、このリポジトリには [settings.json](.vscode/settings.json) を追加してあります。

## ファイル構成

- [main.tex](main.tex): 本文
- [main.bib](main.bib): 参考文献
- [latexmkrc](latexmkrc): ビルド設定と高速化用設定
- `.vscode/settings.json`: VS Code 向け設定
- `build/`: コンパイル生成物

## 参考資料

- ただしい高速LaTeX論. <https://qiita.com/JyJyJcr/items/69769c88eea9d0dae152>. 2026年4月21日閲覧.
