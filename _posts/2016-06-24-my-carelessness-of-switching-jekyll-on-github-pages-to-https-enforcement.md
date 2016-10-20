---
layout: post
title: Github Page の本ブログを HTTPS 強制に移行した際にやらかしたこと
author: cat_in_136
tags:
- "チラシの裏"
date: '2016-06-25T01:07:23+09:00'
modified_time: '2016-10-20T21:50:27+09:00'
---

#### Github Pages 上 jekyll 使ったブログの HTTPS 強制 (HTTPS enforcement) への移行方法

 * Github Pages 移行方法自体は下記の通り至極簡単
   * [Securing your GitHub Pages site with HTTPS - User Documentation](https://help.github.com/articles/securing-your-github-pages-site-with-https/), Github Help.
 * Jekyll の方も config.yml の url を変えるだけ：
   * ```url: "http://cat-in-136.github.io"```→```url: "https://cat-in-136.github.io"```

#### HTTP → HTTPS の変更によって、やらかした外部サーヴィスに関する案件

 * 更新の配信をしている dlvr.it が、https への変更によって新記事と認識し、Twitter への投稿をした件
   * https://twitter.com/cat_in_136/status/746120930556928001 〜 https://twitter.com/cat_in_136/status/746120969731792896
   * 対策としては、一旦無効にしておくべきであった。
   * もし、RSS Reader 経由でここの記事を読んでいる方も同様の現象が発生している恐れ
 * DISQUS の会話内容の消滅
   * URL の移行し忘れであった。
   * 方法は [URL Mapper](https://help.disqus.com/customer/portal/articles/912757-url-mapper) を使用する。


