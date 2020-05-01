---
layout: post
title: GStreamer ximagesrc でウィンドウごとにキャプチャできる件
author: cat_in_136
tags:
- linux
- video
- gstreamer
date: '2020-05-01T18:32:27+09:00'
---
Web上のオンライン会議システムなどで画面共有するさいに、[Screen Capture API]が使われる。
getDisplayMedia demoで試せばすぐわかるがウィンドウ毎にキャプチャ（画面共有）できる。

[Screen Capture API]: https://developer.mozilla.org/en-US/docs/Web/API/Screen_Capture_API/Using_Screen_Capture
[getDisplayMedia demo]: https://www.webrtc-experiment.com/getDisplayMedia/

興味深いのはウィンドウが下に隠れていてもキャプチャされ続けることだ。
コンポジット型ウィンドウマネージャを使う現代において下に隠れているウィンドウは再描画され続けている。
これをそのままキャプチャできるわけだ。
（古典的なキャプチャツールの xwd や ffmpeg の x11grab などでは見たままの通り上にウィンドウが乗っていたらそれがキャプチャされる）

<figure>
{% asset_image_tag fitcontain 2020-05-01_gstreamer-ximagesrc-desktop-composition.svg 384 284 %}
<figcaption>半透明のときは勿論、そうでなくとも下のウィンドウも再描画され続けている</figcaption>
</figure>

これを単にミラーリング的な使い方をしてみたい。

### TL;DR

```
% gst-launch-1.0 -v ximagesrc xid=$XWINDOW_ID ! videoconvert ! autovideosink
```

### ximagesrc

ximagesrc は何もしないとディスプレイ全体を取り込む。
一方で XID を指定して特定のウィンドウを取り込むことができる。

> ```c
> "xid" guint64
> ```
>
> The XID of the window to capture. 0 for the root window (default).

XID というのは X Window の Window id のことだ。
典型的な方法としては xwininfo を使って調べる。

```
% xwininfo                                                                                                  ~

xwininfo: Please select the window about which you
          would like information by clicking the
          mouse in that window.

```

マウスポインタが「＋」の形に変わるので、XID 調べたいウィンドウをクリックすると情報が表示される。

```
xwininfo: Window id: 0xc000007 "Noto Sans CJK JP"

  Absolute upper-left X:  568
  Absolute upper-left Y:  239
  Relative upper-left X:  568
  Relative upper-left Y:  239
  Width: 802
  Height: 641
  Depth: 32
  Visual: 0xc2
  Visual Class: TrueColor
  Border width: 0
  Class: InputOutput
  Colormap: 0xc000006 (not installed)
  Bit Gravity State: NorthWestGravity
  Window Gravity State: NorthWestGravity
  Backing Store State: NotUseful
  Save Under State: no
  Map State: IsViewable
  Override Redirect State: no
  Corners:  +568+239  -550+239  -550-200  +568-200
  -geometry 802x641+568+239
```

長々と貼り付けたが今注目するのは `Window id: 0xc000007` のところだけで XID は `0xc000007` ということになる。
このとき、下記のように入力して使うことになる。

```
% gst-launch-1.0 -v ximagesrc xid=0xc000007 ! videoconvert ! autovideosink
```

なお、XID を調べるのならば `wmctrl -l` を実行して XID 一覧を出してそこから探しても良い。
ただこの手法だと同一のウィンドウ名（タイトル）がある場合は区別が付かない。

### videoconvert ! autovideosink

コンバートをかけて、 autovideosink を指定するといい感じに出力される。

> autovideosink is a video sink that automatically detects an appropriate video sink to use.
> It does so by scanning the registry for all elements that have "Sink" and "Video"
> in the class field of their element information, and also have a non-zero autoplugging rank.

こうしてウィンドウで表示されることになる。

<figure>
{% asset_image_tag fitcontain 2020-05-01_gstreamer-ximagesrc-example.png %}
<figcaption>表示されるウィンドウ</figcaption>
</figure>

こうして表示されたウィンドウはリサイズできるが、キャプチャ対象のウィンドウはリサイズできない。
リサイズするとこの GStreamer が落ちてしまった。
リサイズする度に実行し直しが必要なようだ。

### おまけ：マルチモニタ時の画面キャプチャについて

複数のモニタがつながった大きさのものがそのままキャプチャされてしまう。

<figure>
{% asset_image_tag fitcontain 2020-05-01_gstreamer-ximagesrc-multimonitor-view.png %}
<figcaption>マルチモニタ環境時の ximagesrc 実行結果</figcaption>
</figure>

モニタごとに見るには範囲指定をするしかない。

例えば、一つのモニタのサイズが1920x1080ならば、この例ならばオフセットとして1920を横に付けてやればよい。

<figure>
{% asset_image_object_tag 2020-05-01_gstreamer-ximagesrc-multimonitor-layout.svg %}
<figcaption>横につなげた場合の2枚目のオフセット</figcaption>
</figure>

コマンドとしては例えば下記のようになる。

```
% gst-launch-1.0 -v ximagesrc startx=1920 ! videoconvert ! autovideosink
```

### 参考文献

 * [ximagesrc](https://gstreamer.freedesktop.org/documentation/ximagesrc/index.html), GStreamer API reference
 * [autovideosink](https://gstreamer.freedesktop.org/documentation/autodetect/autovideosink.html), GStreamer API reference
 * [Using Gstreamer to capture screen and show it in a window?](https://stackoverflow.com/questions/33747500/using-gstreamer-to-capture-screen-and-show-it-in-a-window), stackoverflow, May 2017.
