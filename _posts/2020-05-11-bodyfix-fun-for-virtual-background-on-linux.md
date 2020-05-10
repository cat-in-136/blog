---
layout: post
title: Linux上でbodypixを使ってバーチャル背景を実現する試み
tags:
- gstreamer
- linux
- virtual background
thumbnail: "{% asset_image_path 2020-05-11-bodypix-fun-for-virtual-ground-on-linux-demo-roman-holiday.jpg
  %}"
date: '2020-05-11T00:31:01+09:00'
---

Snap Cameraの linux 版がないせいで…
多くの linux ユーザがバーチャル背景を実現しようと…と予想していたが、
あんまし記事が上がっていないので書いておく。

### TL;DR

[https://github.com/cat-in-136/bodypix-fun/blob/master/README.md](https://github.com/cat-in-136/bodypix-fun/blob/master/README.md)

### 合成

先行事例[Open Source Virtual Background \| BenTheElder](https://elder.dev/posts/open-source-virtual-background/)で、BodyPixの実行を GPU 支援を有効にした docker 上の Node.js でサーバプログラムとして実行して、他を python でやるという回りくどいことをやっていたので、これは面倒くさいということで、早速この成果をベースに自分自身で拵えてみようということになったのである。

まずは、Jitsi meet の背景ブラーにも使われているオープンソースのライブラリ [BodyPix](https://github.com/tensorflow/tfjs-models/tree/master/body-pix) を使って、簡単なバーチャル背景合成をするプログラムを作るところから始めた。

bodypix は TensorFlow.js ベースでありブラウザ・Node.jsのどちらでも推論を実行させることができる。
ブラウザで動かすとブラウザの外に持っていくのが面倒なので Node.js で動かすこととした。

処理自体は簡単で、bodypix で推論を実行`net.segmentPerson()`してやると`data`に
人物が入ったところに 1 が、そうでないところに 0 が入った二値画像が生成される。
これをマスクとして背景画像とカメラ画像を合成してやれば良い。

この初回の実装は非常に雑なので説明は省略するが、bodypix 以外のところが重く
640x480 のサイズでさえ一周で1秒超えという非常に遅いものが出来上がった。
TensorFlow の様々な高速化を台無しにする他の処理の重さはダメだろうということで見直しが必要となった。
そこでカメラ処理や画像合成処理において高速に動きそうなライブラリを使う必要性をきづいたわけである。

昔ながらからあるこの手の定番のライブラリである OpenCV を Node.js から使うことができる
[opencv4nodejs](https://www.npmjs.com/package/opencv4nodejs) を見つけたため、これで
カメラの扱いとマスク合成などの画像処理を行うこととした。

```javascript
// ...
const tf = require('@tensorflow/tfjs-node-gpu');
const bodyPix = require('@tensorflow-models/body-pix');
const cv = require('opencv4nodejs');

(async () => {
  const vCap = new cv.VideoCapture(argv['input']);
  // ...

  const background = (!!argv['background']) ?
    cv.imread(argv['background']).resize(height, width) :
    new cv.Mat(height, width, cv.CV_8UC3, [0, 255, 0]);

  // ...

  try {
    while (true) {
      let frame = vCap.read();
      if (frame.empty) { break; }
      frame = frame.resize(height, width);

      console.time('bodyPix');
      const image = tf.tensor3d(await frame.getData(), [height, width, 3]);
      const { data } = await net.segmentPerson(image, {
        flipHorizontal: false,
        internalResolution: 'medium',
        segmentationThreshold: 0.7,
      });
      image.dispose();
      console.timeEnd('bodyPix');
      const mask = new cv.Mat(new Uint8Array(data), height, width, cv.CV_8U);

      const outFrame = new cv.Mat(height, width, frame.type);
      background.copyTo(outFrame);
      frame.copyTo(outFrame, mask);

      // ...

      if (argv['preview']) {
        cv.imshow('out', outFrame);
        // ...
      }
    }
    // ...
  }
})();
```

上におおよその処理の流れを示した。bodypix 以外の処理は OpenCV で書いたが、
TensorFlow.js でも書けると思うが、今はこうしてある。

bodypix のよくあるサンプルプログラムでは `image.dispose()` に相当する処理が
抜けているがこれを実行しないとメモリを食いつぶすので注意が必要だ。
OpenCV は自動開放してくれるらしくこのような手動での開放処理は無くとも問題は発生しなかった。

プログラム自体は [cat-in-136/bodypix-fun](https://github.com/cat-in-136/bodypix-fun) にあげたが、
`npm i` を実行したら（OpenCVのコンパイルをするので時間がそれなりにかかる）、
下記のように実行すれば良い。`--help` で使い方も出すようにしてあるので詳細は参照されたし。

    % node ./app.js -i 0 --preview -b 背景画像.jpg

### 仮想ウェブカメラとの結合

昔からあるので、また定番なため有名化と思うが [v4l2loopback](https://github.com/umlaeute/v4l2loopback) を入れれば良い。

[README](https://github.com/umlaeute/v4l2loopback/blob/master/README.md) を読め、だけの話だが、例えば下記のようにすると `/dev/video2` という仮想ウェブカメラの v4l2 device file が生えてくる

    % sudo modprobe v4l2loopback devices=1 video_nr=2 exclusive_caps=1

`exclusive_caps=1` がポイントで、これがないと単なるキャプチャデバイス扱いになるのか、ブラウザから選べないので今回の用途では必ず追加しておく必要がある。

あとは `/dev/video2` に前述の合成結果を流し込めばいい。

OpenCV のウィンドウに出す機能 (`cv.imshow()`) も動いたので、これで画面を表示して、
[GStreamer ximagesrc でウィンドウごとにキャプチャ]({% post_url 2020-05-01-gstreamer-ximagesrc-to-capture-window %})して、
`v4l2sink`に流し込むことにした。

    % gst-launch-1.0 -v ximagesrc xid=$XWINDOW_ID use-damage=false ! \
         videoconvert ! \
         videoscale ! \
         "video/x-raw,width=640,height=480,framerate=30/1,format=YUY2" ! \
         v4l2sink device=/dev/video2

`$XWINDOW_ID` は `xwininfo(1)` で調べて各自の環境に変えること。

いまは GStreamer を使ったが、OBS Studio を使ってウィンドウをキャプチャして、
それを [obs-v4l2sink](https://github.com/CatxFish/obs-v4l2sink) で流し込んでも良い。

あとはオンライン会議アプリから仮想ウェブカメラを読み取れば良い。

### ウィンドウキャプチャを介する「ズル」を克服しようとして挫折

仮想ウェブカメラに投入する所でウィンドウキャプチャを介することとしたが、
これははっきり言ってズルである。

ここのズルをなんとかしようと数日頑張ったが、結局 JavaScript というかロジックの難解さもしくはマルチメディアフレームワークの難解さから切り上げることとした。

真面目に実装する場合は、画像データを適切な形式にして仮想ウェブカメラの v4l2 loopback device に投げ込まないといけない。
ただ、 bodypix の処理が重かったりばらつきがでるのでいわゆるフレーム落ちを考慮して非同期処理として
一種のキューイング処理が必要となる。これはこれで面倒くさく、また汎用性が欠ける。

そこでウィンドウキャプチャをして仮想ウェブカメラに GStreamer を使ったのであるが、
Node.js から直接 GStreamer を叩いて v4l2 loopback device に投入することを考えた。

GStreamer はなんでもありな非常にリッチなマルチメディアフレームワークであって、
動画（や音声）の一連の処理を、
複数の source/filter/sink からなる一連のパイプライン処理として行い、
それらのエレメントを変えてやれば同様の処理が容易にできる。
例えば sink をストリーミングにすればストリーミングできるし、
同様にしてウィンドウ表示、ファイル保存もできる。filter も同様だ。

ただ、これはあくまで実現性の話で、そういう風に作れるかどうかはフレームワークを使うプログラマに委ねられている。
実際にはエレメントを変えれば勝手にいい感じにしてくれる魔法が働いているわけではなく、形式変換を指示していかなければならない。
パイプラインを play する際にネゴシエーションが行われて、解決可能な場合は解決して形式を補ってくれる。
複雑なパイプラインを組んでいくとネゴシエーションが不十分なので、色々と指示する必要がある。
サイズはあっているか変更するか、フォーマットはあっているか、タイミング(framerate)はあっているか、処理速度のばらつきなどのためキューイングは必要か、…などだ。

この形式変換を指示していかなければならないのは、フレームワークを使う側になっている（という設計方針だろう）。
ただ、問題は、合わなかったときにエラーメッセージが貧弱であり、ひどい場合は何も出力されないまま正常終了するのである。
これは非常に辛く、困難を極めて力が及ばなかった。

というわけで、ズルをしない方法にするのは諦めた。
今の OpenCV の手法で10fps程度の処理速度はでているため、いったん完了とした。

### バグ: FATAL: Module v4l2loopback is in use.

v4l2 loopback device が busy 状態になって以後使えなくなるバグがある。
原因はわかっていない。

### おまけ: ウェブカメラ画像じゃなくて動画に適用してみた図

bodypix-fun は、OpenCV のビデオキャプチャ処理 `new cv.VideoCapture()` が、
ビデオデバイス入力とカメラを切り替えが容易なのでそういうふうにも作ってある。
`node app.js -i foobar.mp4 --preview` のように実行すれば良い。

<figure>
{% asset_image_tag 2020-05-11-bodypix-fun-for-virtual-ground-on-linux-demo-roman-holiday.jpg %}
<figcaption>動画に適用してみた例。「ローマの休日」より</figcaption>
</figure>

### 参考文献

 * Benjamin Elder, "[Open Source Virtual Background](https://elder.dev/posts/open-source-virtual-background/)", April 9th, 2020
 * Takatsugu Nokubi, [任意のバーチャル背景を使えるページを作った](https://qiita.com/knok/items/b3eb87769151ac04efeb), Qiita
 * tfujiwar418, [TensorFlow.jsがWebGLで並列計算を実行する仕組みを理解する - 開発日誌](http://tfujiwar.hatenablog.com/entry/2018/05/21/120815)
