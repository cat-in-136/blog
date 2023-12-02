---
layout: post
title: OSDNからのデータ救出に関する参考情報
tags:
- チラシの裏
- データ移行
date: '2023-12-02T16:19:59+09:00'
last_modified_at: '2023-12-02T16:28:05+09:00'
---

2023年7月に、OSCHINA が OSDN の買収を発表した。しかし、[OSCHINA のプレスリリース](https://www.oschina.net/news/250642/oschina-acquired-osdn)によると、買収は 2022年に行われたとされている。

<blockquote cite="https://www.oschina.net/news/250642/oschina-acquired-osdn" lang="zh-CN">
<p>2022 年，开源中国 (OSCHINA) 正式收购日本老牌开源社区 OSDN。</p>
</blockquote>

プレスリリースでは、OSDN の歴史と OSCHINA の歴史が紹介され、オープンソースソフトウェアの発展や中国企業のソフトウェア開発の効率化に貢献したことが述べられている。しかし、OSDN の撤退や運用・保守の強化について言及されていない。

一般的に、企業が他の企業を買収する場合、買収した企業の運用・保守を強化したり、統合したりするのが普通である。しかし、OSDN は買収後も接続できない状況が続いている。

本稿は、OSDN が根本的に接続不能になる前に、できることをメモしたものである。


## アクセス状況

OSDN へのアクセスは一部可能だが、ログインはできない。ログインすると PHP の CGI に飛ぶが、そこでエラーになる。そのため、ログインもユーザページの閲覧もできない状態になっている。

## ソースコードの取得

現時点では、ソースコードを入手することは可能だ。

OSDNが生きていたころにSSHキーを設定し、それがまだ.sshに残っている場合は、以下のコマンドでアクセスできる。

```console
$ git clone アカウント名@git.osdn.net:/gitroot/プロジェクト名/レポジトリ名.git
```

sourceforge.jp は現在 osdn.net になっているが、リダイレクトされているため、昔と変わらず git.sourceforge.jp でもアクセスできる。

```console
$ git clone アカウント名@git.sourceforge.jp:/gitroot/プロジェクト名/レポジトリ名.git
```

他人のプロジェクトのソースを取得するには、 `git clone` の際に HTTPS アクセスする必要がある。
また、OSDN にログインできないため、公開鍵の新規登録設定ができない状況にある。そのため、SSH キーが何らかの理由で使えない状況にある場合にも同様に、HTTPS アクセスが必須である。

HTTPS アクセスでは TLS 証明書エラーが出るため、環境変数 `GIT_SSL_NO_VERIFY` を設定して証明書検証を無効にして `git clone` する。
この場合、OSDN アカウントがなくても readonly アクセスが可能になる。

```console
$ GIT_SSL_NO_VERIFY=true git clone https://git.osdn.net/gitroot/プロジェクト名/レポジトリ名.git
```

Web インタフェースの `https://ja.osdn.net/projects/プロジェクト名/scm/git/レポジトリ名/` は非常に重く遅い。
旧 Web インタフェースの `http://git.osdn.net/view?p=プロジェクト名/レポジトリ名.git` からは快適に閲覧可能。

## ホームページおよびサーバデータの救出

Web サーバは死んでいるが、SSH/SCP でファイルの救出は可能。
`/home/groups/プロジェクト名の先頭1字/プロジェクト名の先頭2字/プロジェクト名/` にプロジェクトのホームページの内容がある。

```console
$ ssh -2 -C shell.osdn.net -l ユーザ名
ユーザ名@sf-usr-shell:~$ uname -a
Linux sf-usr-shell 3.16.0-11-amd64 #1 SMP Debian 3.16.84-1 (2020-06-09) x86_64 GNU/Linux
```

## リリースファイルのダウンロード

リリースページ（ https://ja.osdn.net/projects/プロジェクト名/releases/リリース番号 ）にはダウンロードファイルが表示されず、またダウンロードも不可な状態になってしまっている。

ダウンロードする場合は、直接ミラーサイトを参照することでリリースファイルをダウンロードできる。例えば、IIJ のサイトを参照することでダウンロードできる。

`https://ftp.iij.ad.jp/pub/osdn.jp/プロジェクト名/`


## References

* [开源中国收购日本老牌开源社区 OSDN \- OSCHINA \- 中文开源技术交流社区](https://www.oschina.net/news/250642/oschina-acquired-osdn)
* [中国のオープンソースコミュニティ OSCHINA が OSDN を取得、サイトは独立を維持 \| スラド オープンソース](https://opensource.srad.jp/story/23/07/27/0555240/)
* [OSDNのミラーコンテンツ 2023/11/19](https://gist.github.com/shujisado/2864e2475567fbbad8f8bacdb290d48a)


