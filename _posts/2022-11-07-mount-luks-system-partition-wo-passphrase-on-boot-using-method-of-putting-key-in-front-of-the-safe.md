---
layout: post
title: 起動時にパスフレーズなしでLUKS暗号化システムパーティションをマウントする方法、金庫の前に鍵を置く方式
date: '2022-11-07T00:55:37+09:00'
tags:
- luks
- linux
- dracut
last_modified_at: '2023-01-21T09:09:01+09:00'
---

ずっとわからなかった、 Fedora Linux における LUKS パーティションを起動時にパスフレーズ入力を省く方法がやっとわかった。

もちろんパスフレーズを入力しないということはパスフレーズ相当の代物であるキーファイルを非暗号化領域に置くことだから、金庫の前に鍵を置ようなセキュリティ強度となる。
SSD/HDD廃棄時にキーファイルの置いてある箇所のみ念入りに抹消すればいいぐらいのメリットになる。

## ブートじゃないときで、パスフレーズなしでLUKS暗号化システムパーティションをマウントする方法

パスフレーズがわりのキーファイルをつくる。キーファイルはなんでもいいのだが、乱数から作ったものが一般に好ましい。

```console
# dd bs=1024 count=1 if=/dev/urandom of=/etc/keyfile-xxxxx iflag=fullblock
# chmod 0400 /etc/keyfile-xxxxx
```

このキーファイルを LUKS パーティションに紐付ける。なお既存のパスフレーズの入力が必要となる。

```console
# cryptsetup luksAddKey /dev/sdx1 /etc/keyfile-xxxxx

Enter your old/existing passphrase here. Expected output:
Key slot 0 unlocked.
Command successful.
```

キーファイルとLUKSパーティションの紐付けをsystemdに教える仕組みを用意しなければならない。
これには `/etc/crypttab` というファイルを使う。

もし `/etc/crypttab` がない場合は、ファイルを作って適切な権限を付与する。

```console
# touch /etc/crypttab
# chown root:root /etc/crypttab
# chmod 0744 /etc/crypttab
```

`/etc/crypttab` には例えば下記のように書く。

```
VolumeLabel   UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx /etc/keyfile-xxxxx    luks,timeout=10s
```

すなわち、ボリュームラベル・暗号化デバイス・キーファイル・オプションのの順番に書いた行を足す。

こうすると mount するときに systemd は、この `/etc/crypttab` を参照し、マウントしようとしているデバイス（のUUID）に紐付けられたキーファイルを探し、このキーファイルを使って LUKS パーティションを復号化する。

## ブート時に不足しているもの

しかしこれはシステムパーティション、すなわちマウント先がルート ( `/` ) の場合はうまく行かない。

* ブートプロセスでは、ルート ( `/` ) をマウントする前に initramfs イメージをマウントして動作している
* initramfs に追加設定しない限り、前節で言及したファイルは initramfs に含まれない

したがって、一連の設定に必要なファイルを initramfs に追加する必要がある。


initramfs の実体は、 `/boot/initramfs-5.xx.xx-xxx.fc36.x86_64.img` といった名前のイメージファイルである（`5.xx.xx-xxx.fc36.x86_64` はカーネルリリース名。 `uname -r` に対応する）。
この中身の一覧は `lsinitrd` コマンドで見れる。`/etc/crypttab` はあるがキーファイルは存在しない。

```console
# lsinitrd | grep crypttab
-rw-r--r--   1 root     root          120 Sep 26 23:47 etc/crypttab
# lsinitrd | grep keyfile-xxxx
#
```

方針としてはキーファイルをブート時に参照できるようにする、 initramfs に含めてしまうということを考える

## 起動時にパスフレーズなしでLUKS暗号化システムパーティションをマウントする方法、金庫の前に鍵を置く方式

パスフレーズがわりのキーファイルをつくってキーファイルを LUKS パーティションに紐付ける。
これは起動後の通常の場合と同じ方法

```console
# dd bs=1024 count=1 if=/dev/urandom of=/boot/keyfile-xxxxx iflag=fullblock
# chmod 0400 /boot/keyfile-xxxxx
# cryptsetup luksAddKey /dev/sdx1 /boot/keyfile-xxxxx
```

そして `/etc/crypttab` には例えば下記のように書く。ボリュームラベルbootと暗号化デバイス（のUUID）とキーファイルを紐付ける。
これも起動後の通常の場合と同じ

```
root   UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx /boot/keyfile-xxxxx    luks,timeout=10,discard
```

ここでSSDの場合は上記のように `discard` と設定して discard/TRIM を有効してもよい。
論理ボリュームがその基底となる物理ボリュームの領域をもはや使用しなくなるとその物理ボリュームに discard 要求が飛ぶため、
開放されたブロック情報という形でデータが漏洩する可能性が僅かにあるためセキュリティ的な事情から暗号化ストレージでは有効にすべきではない、
という意見がある。([Milan Broz's blog: TRIM & dm-crypt ... problems?](http://asalor.blogspot.com/2011/08/trim-dm-crypt-problems.html)に詳しい)
しかしながら、いま暗号化鍵は金庫の前に置かれている状態であり、このような攻撃ができている場合には暗号化鍵を取得できている状態であるから、
このセキュリティリスクはもはや考慮する必要性がない。純粋に discard/TRIM を有効にするかしないかだけを考えて決めればよい。

initramfs イメージファイルは dracut で作られる。 dracut にキーファイルも initramfs に含めるようにする。

```console
# vim /etc/dracut.conf.d/copy-keyfile.conf
# cat /etc/dracut.conf.d/copy-keyfile.conf
install_items+=/boot/keyfile-xxxx
```

あとは dracut で initramfs を作り直せば良い…のだが、この段階で **現在の initramfs をバックアップしておく** こと。initramfs の復元生成は非常にむずかしいからバックアップをしておいて、万が一の失敗時には rescue モードや Live DVD かで入って、 boot パーティションに置いてある initramfs のファイルを差し戻すだけで起動可能な状態に戻せるようにしておくと楽である。

```console
# cp -p /boot/initramfs-5.xx.xx-xxx.fc36.x86_64.img /boot/initramfs-5.xx.xx-xxx.fc36.x86_64.img.ORIG
```

もちろん boot パーティションまるごとディスクイメージファイルを作るなどの回避策でも良い。

initramfs イメージファイルを更新生成するには下記のように実行する。時間がかかるので待つこと。

```console
# dracut -f
```

処理が終わったら initramfs イメージファイルのなかにキーファイルが格納されていることを確認する。

```console
# lsinitrd | grep boot/keyfile
-r--------   1 root     root         1024 Oct 30  2022 boot/keyfile-xxxx
```

これにて終わり。次回起動移行はパスフレーズを入力する必要はない。

## 補足

> 金庫の前に鍵を置ようなセキュリティ強度となる。

と冒頭で書いたが initramfs イメージファイルの中身に格納されるので、金庫の扉に鍵を貼り付けておくぐらいのイメージに近い。
initramfs は GZip 圧縮された CPIO アーカイブファイルであるから極めて簡単に initramfs の中のファイルを抽出可能である（他の形式も選択可能ではあるが同様に取り出しは用意）

## 参考文献

* [centos - Automatic LUKS unlock using keyfile on boot partition - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/666770/automatic-luks-unlock-using-keyfile-on-boot-partition#answer-666772) (pauldoo's answer)
* [dm-crypt/Device encryption - ArchWiki](https://wiki.archlinux.org/title/Dm-crypt/Device_encryption)
* [dracut/dracut.usage.asc at master · dracutdevs/dracut](https://github.com/dracutdevs/dracut/blob/master/man/dracut.usage.asc) (dracut user manual)
