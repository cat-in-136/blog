---
layout: post
title: TermuxでコンパイルしたELFバイナリに関するメモ
tags: チラシの裏 android
date: '2019-08-26T00:07:15+09:00'
---
[Termux](https://termux.com/)という、非rootで使えるLinux CUI環境というかアプリがある。
これで興味深いのはパッケージ管理システムが提供されていて、clangが入れられる。
(なお、gccは提供されていない)

<figure>
{% asset_image_tag fitcontain 2019-08-25-screen.png 360 640 %}
<figcaption>"Hello, world."コンパイルと実行の様子</figcaption>
</figure>

これは本当にARM aarch64なELFバイナリファイルを生成している。

Termuxの仕組みは`/data/data/com.termux/files/`をprefixとした環境になっているので、
`/data/data/com.termux/files/usr/lib`にいろいろな共有ライブラリ(dynamic library)がある。

ところで、上で作ったhelloファイルが必要とする共有ライブラリは、`libdl.so`と`libc.so`なのだが、
`/data/data/com.termux/files/usr/lib`には存在しなかった。
調べてみたところ、`/system/lib/libdl.so`と`/system/lib/libc.so`を参照しているようであった。
つまり、システムで使えるものは使う方針のようだ。

adbからアクセスできる`/data/local/tmp/`にコピーしたら、非Termux環境で使えた。

方法は以下の通り。

一旦Termuxでsdcard領域に退避させる。

    $ pwd
    /data/data/com.termux/files/home
    $ cp hello storage/shared

これをadbから`/data/local/tmp/`にコピーする。これはsdcard領域では実行権限が付与できないからである。

    $ adb shell
    $ cp /sdcard/hello /data/local/tmp
    $ chmod +x /data/local/tmp/hello
    $ /data/local/tmp/hello
    Hello, world.
    $

しかし実用的にはPC上でクロスコンパイルしたほうがうんと楽であろうから、
単なる小ネタではある。


