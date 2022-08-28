---
layout: post
title: Linux上のpodman上でqmk flashすることに関するメモ
author: cat_in_136
tags:
- qmk
- podman
- linux
- 自作キーボード
date: '2022-08-28T15:21:33+09:00'
---

いわゆる自作キーボードにおける pro micro へファームウェアをflashする（焼く）のを Linux 上の podman コンテナ内でなんとかするための試みに関するメモ

今どきはキーマップぐらいの変更ならば Google Chrome/Chromium つかって [Remap](https://remap-keys.app) でflashするのが圧倒的に楽ではある。QMK をカスタムすること、あるいは何らかの宗教上の理由などで Google Chrome/Chromium を使えないときには CLI で焼く必要がある

本稿で紹介する方法は、USBデバイスの設定である udev と QMK のファームウェア以外はコンテナ上で動かすことで、ホスト環境への影響をなくすとともにセットアップをかんたんにしている

なお、podman で確認したが docker ユーザの場合は docker に読み替えても実行できるはずだ

### udev

USB接続した pro micro を linux PC に認識させる必要がある。 `/etc/udev/rules.d/` に udev のルールをインストールする

ルールは [qmk/qmk_firmware](https://github.com/qmk/qmk_firmware) の中にあって、下記から落とすのが良い

<https://github.com/qmk/qmk_firmware/tree/master/util/udev/50-qmk.rules>

ところで、キーボードによっては USB Vendor ID , Product ID を書き換えているものがある。その場合は、そのキーボード用にルールをつくる必要がある

たとえば、 meishi2 keyboard ( [biacco42/meishi2](https://github.com/Biacco42/meishi2) ) の場合は、 Vendor ID を`bc42` Product ID を `0003` としていたため、そのルールを書く必要がある。具体的には、下記のルールを `50-qmk.rules` に追記するか、別のルールファイルとして作った上で `/etc/udev/rules.d/` に置くこと

```
## meishi2
SUBSYSTEMS=="usb", ATTRS{idVendor}=="bc42", ATTRS{idProduct}=="0003", TAG+="uaccess"
```

作業が終わったら下記コマンドで udev のルールを反映させる（再起動不要）

```console
$ sudo udevadm control --reload-rules
```

### qmk_firmware

[qmk/qmk_firmware](https://github.com/qmk/qmk_firmware) を入手する

この作業は必須ではないが、結局ソースコードをいじったりするのが  Remap などを使わずにビルドする主目的であるから、 `git clone` する(そこそこサイズが大きいので気になる人は partial clone などをしたほうが良いかもしれない)

```console
$ git clone --recurse-submodules https://github.com/qmk/qmk_firmware.git
```

なお後述の qmk_cli の docker イメージをあたらしいものに更新したら、 qmk_firmware も `git pull` して新しくしたほうがよいだろう。逆もしかり

### qmkのインストールなどが必要だが、、、

python pip で qmk のインストールなどが必要だが、いろいろとインストールが面倒なので、コンテナを使うこととする

QMK 謹製のイメージが docker hub にあがっているのでそれを使う

### qmk_cli イメージを使ってビルド

QMK 謹製のイメージとして [qmkfm/qmk_cli](https://hub.docker.com/r/qmkfm/qmk_cli) がある。これには、QMK のビルドとキーボードにflashする一連の作業に必要なものがほとんど入っている

結論から言うと、下記のように実行すればよい（当然 `podman pull` は初回のみで良い）。`-kb` にはキーボードの名前、`-km` にはキーマップの名前を書く

```console
$ podman pull qmkfm/qmk_cli
$ podman run --rm -it -v `pwd`/qmk_firmware:/qmk_firmware:z qmkfm/qmk_cli \
  /bin/bash -c \
  "qmk setup && qmk compile -kb biacco42/meishi2 -km default"
```

多くの和文のブログ記事などでは make コマンドでビルドを行っているが、QMK のユーザマニュアルには `qmk` コマンドのほうが書かれているのでこちらを採用した

qmk_firmware のところで [qmk/qmk_firmware](https://github.com/qmk/qmk_firmware.git) の入手が必須ではないといったが、これを省いた場合は <code>-v `pwd`/qmk_firmware:/qmk_firmware:z</code> を削除すること。このとき、コンテナ内の `/qmk_firmware` に [qmk/qmk_firmware](https://github.com/qmk/qmk_firmware.git) がダウンロードされる

上の例ではホスト側にある `qmk_firmware` ディレクトリをコンテナ内のボリュームとして割り当てている。この場合でも `qmk setup` は必要ではあるが、このときは [qmk/qmk_firmware](https://github.com/qmk/qmk_firmware.git) がダウンロードされずに、いまある `/qmk_firmware` が使われる

注意点

* SELinux を有効にしていることを想定しているため <code>-v `pwd`/qmk_firmware:/qmk_firmware:z</code> のように末尾に `:z` をつけている。SELinux 有効環境下で `:z` を付けないとコンテナ内から `qmk_firmware` ディレクトリにアクセスするときに権限エラー (permission denied) となる

なお既述のとおり qmk_firmware を `git pull` して新しくしたら、 qmk_cli の docker イメージもあたらしいものに更新したほうがよいだろう。逆もしかり

### qmk_cli イメージを使ってflash

下記のように実行すればよい。`-kb` にはキーボードの名前、`-km` にはキーマップの名前を書く

```console
$ sudo setsebool -P container_use_devices 1
$ podman run --rm -it -v `pwd`/qmk_firmware:/qmk_firmware:z -v /dev:/dev:rw qmkfm/qmk_cli \
  /bin/bash -c \
  "qmk setup && qmk flash -kb biacco42/meishi2 -km default"
…（出力中略）…
Linking: .build/biacco42_meishi2_default.elf                                                        [OK]
Creating load file for flashing: .build/biacco42_meishi2_default.hex                                [OK]
Copying biacco42_meishi2_default.hex to qmk_firmware folder                                         [OK]
Checking file size of biacco42_meishi2_default.hex                                                  [OK]
 * The firmware size is fine - 20726/28672 (72%, 7946 bytes free)
Waiting for USB serial port - reset your controller now (Ctrl+C to cancel)..............................
```

この `Waiting for USB serial port - reset your controller now (Ctrl+C to cancel)` が出たところで、書いてあるとおり pro micro をリセットする。すなわち pro micro の RST を GND に短絡させる。通常はキーボード側にリセットボタンがあるはずなので、それを押す

リセットする（リセットボタンを押す）と `/dev/ttyACM0` といった pro micro のデバイスファイルが linux PC 上に生えたのを qmk コマンドが検知して先に進み、ファームウェアが flash されてコマンドの実行が終わる

注意点

* `-v /dev:/dev:rw` を指定して `/dev/` 以下をコンテナ内に見せている。`--device /dev/ttyACM0` のような指定でも良いはずであるが、デバイスファイルがリセット時に変わったりしたりするため `/dev/` をそのまま見せている。もし、これを指定し忘れるとデバイスファイルが見つからないため `Waiting for USB serial port - reset your controller now (Ctrl+C to cancel)........` のメッセージが出たまま先に進まないという現象になる
* `sudo setsebool -P container_use_devices 1` は初回一回のみでよいが、SELinux 環境下では必須で、これがないとコンテナ内からデバイスをアクセスする権限がないため権限エラーとなる。未設定時のエラーメッセージは OCI permission denied であるが、SELinux のエラーログを見れば `container_use_devices` を設定することが書いているので、それをもとに従えばよい


### keymap JSON ファイルからflashするには

簡易的な手段として、[QMK Configurator](https://config.qmk.fm/)などからエクスポートするなどして得たキーマップのJSONファイルからファームウェアをビルドしてflashすることもできる。qmk_cli はこの JSON ファイルに対応しているから、`qmk_firmware` の中に JSON ファイルを置いた上で `qmk flash` を実行すれば良い

例えばカスタムしたキーマップを `qmk_firmware/biacco42_meishi2_layout_mine.json` に置いたら、下記のように実行すれば良い。JSON ファイルにキーボード情報が書かれているので `-kb` オプションは不要である

```console
$ podman run --rm -it -v `pwd`/qmk_firmware:/qmk_firmware:z -v /dev:/dev:rw qmkfm/qmk_cli \
  /bin/bash -c \
  "qmk setup && qmk flash biacco42_meishi2_layout_mine.json"
```

### 参考文献

* [qmk\_firmware/faq\_build.md at master · qmk/qmk\_firmware](https://github.com/qmk/qmk_firmware/blob/master/docs/ja/faq_build.md)
* [qmk\_firmware/cli\_commands.md at master · qmk/qmk\_firmware](https://github.com/qmk/qmk_firmware/blob/master/docs/cli_commands.md)
* [Building Your First Firmware](https://docs.qmk.fm/#/newbs_building_firmware)
* [Flashing Firmware](https://docs.qmk.fm/#/newbs_flashing)
