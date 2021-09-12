---
layout: post
title: ぜんぜんわからない俺達は雰囲気でbtrfs使っている
author: cat_in_136
tags:
- btrfs
- linux
- filesystem
thumbnail: "{% asset_image_path 2020-09-13-Btrfs_logo.svg %}"
date: '2021-09-13T00:07:08+09:00'
---

雰囲気で ext2/3/4 を使ってきた人が、雰囲気で btrfs を使うためのメモ。
RAID は本稿では深く触れない。 RAID は雰囲気で使えるものではない。

<figure>
{% asset_image_tag fitcontain 2020-09-13-Btrfs_logo.svg %}
</figure>

### 発音

何かと話にあがるどう発音するか問題については、下記が答えで良いと思われる。

> It's called Butter FS or B-tree FS, but all the cool kids say Butter FS
>
> --- Valerie Henson, "Chunkfs: Fast file system check and repair", 31 Jan 2008.

クールキッズなら **バター・エフ・エス**  [bʌ́tə(r) - éf - es] と発音すれば良い。

<figure>
<figcaption>"Butter FS" 発音部を抜き出したもの</figcaption>
<audio controls="controls"
       src="data:audio/ogg;base64,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">
</audio>
</figure>

### とにかくささっと使うには

ファイルを仮想ドライブとして使えばひとまず試用することができる。
128MBのbtrfsストレージ使う方法。

```bash
$ fallocate -l 128M butter.img
$ mkfs.btrfs butter.img
$ mkdir mountpoint
$ sudo mount -t auto butter.img mountpoint
$ sudo chown $USER:$USER mountpoint
```

* 128MB未満はbtrfsの仕様として対応していない。
* `fallocate` が使えない異常に古いファイルシステムをお使いの方は `dd`
  で所望のサイズのファイルをつくるなどしてください。
* BtrfsやzfsなどのCoWファイルシステム上でこのような使い方をする場合、
  CoWによってパフォーマンスの影響が出るため `chattr +C butter.img` を実行するなどして
  仮想ドライブとして使うファイルには CoW が無効化させておくのが良い。

#### RAIDとかのときはブロックデバイスが必要なので

RAIDとかのときはブロックデバイスが必要なのでbrdモジュールを使いましょう。

```bash
$ sudo modprobe brd rd_nr=2 rd_size=131072
$ sudo mkfs.btrfs /dev/ram0 /dev/ram1
$ mkdir mountpoint
$ sudo mount -t auto /dev/ram0 mountpoint
```

使い終わったらモジュールごと消せば良い。

```bash
$ sudo modprobe -r brd
```

### 遅延書き込み

ファイル書き込みをしても btrfs は容量を消費しないように表示される。

```bash
$ dd bs=1024 count=1024 if=/dev/random of=1MB_file
$ btrfs filesystem du 1MB_file
     Total   Exclusive  Set shared  Filename
     0.00B       0.00B       0.00B  1MB_file
```

この状態ではファイルの実体は書き込まれていない。
しばらく経つと、ディスクに書き込まれるので容量を消費する。

```bash
$ btrfs filesystem du 1MB_file
     Total   Exclusive  Set shared  Filename
   1.00MiB     1.00MiB       0.00B  1MB_file
```

明示的にディスクに書き込み指示するには `sync` コマンドを打ちましょう。

#### 遅延書き込み時間の設定

mountオプションで `-o commit=180` のように設定することで、ディスクへの書き込み時間間隔を調整できる。

> **commit=seconds**
> : (since: 3.12, default: 30)
> :
> : Set the interval of periodic transaction commit when data are synchronized to permanent storage. Higher interval values lead to larger amount of unwritten data, which has obvious consequences when the system crashes. The upper bound is not forced, but a warning is printed if it’s more than 300 seconds (5 minutes). Use with care.
>
> --- [Manpage/btrfs\(5\) - btrfs Wiki](https://btrfs.wiki.kernel.org/index.php/Manpage/btrfs%285%29)

途中で変える場合は `remount` コマンドを使いましょう。

```bash
$ sudo mount -o remount,commit=120 mountpoint
```

#### 遅延書き込みの弊害

* 異常終了（停電・カーネルクラッシュ）すると、ファイルが消える。
  * 実態は、ディスクに書き込む前だったというだけ。人間にはあたかも消えたように見える。
* 一時的にファイルを作って消すような場合はディスク書き込みがないため速い。
  * コミットインターバルのタイミングで書き込みがあるので処理が遅くなる。
  * 単純にファイルを作るだけではベンチマークにはまったくならない。

#### 遅延書き込みを見てみる

メタデータだけは直ちに作成され `hello.txt` という文字列がディスクに書き込みされる。
ファイルの中身は遅れて書き込みされることがわかる。

```bash
$ fallocate -l 128M clean.img
$ mkfs.btrfs clean.img
$ mkdir mountpoint
$ sudo mount -t auto clean.img mountpoint
$ sudo chown $USER:$USER mountpoint

$ echo hello > mountpoint/hello.txt
$ strings clean.img | grep -i hello | sort | uniq
hello.txt

$ sync
$ strings clean.img | grep -i hello | sort | uniq
hello
hello.txt
```

#### 遅延書き込みまとめ

* btrfs はデータは遅れて書き込まれるよ
* コミットインターバルは設定で変えられるよ
* コミットインターバルが来る前はディスクに書き込まれていないから、異常終了すると消えたように見えるよ。

### Copy-on-Write : CoW

> btrfs is a modern copy on write (CoW) filesystem for Linux aimed at implementing advanced features while also focusing on fault tolerance, repair and easy administration.
>
> --- [btrfs Wiki](https://btrfs.wiki.kernel.org/index.php/Main_Page)

* コピーしても実体はコピーされずに、参照をつくるだけでコピー時間や使用容量を削減する。その後に書き換えた際にはじめて実際にその箇所がコピーされ容量を消費する
* 新しいデータはディスクの空き容量に書き込んでから、新しいデータを参照するようにファイルのメタデータを変更する。元のデータはどこからも参照されなくなってはじめて削除する。
* 書き込み途中で死んでもファイルが消えることはないから安全！

#### コピーしても中身は共有されている

```bash
$ cd mountpoint
$ dd bs=1024 count=1024 if=/dev/random of=1MB_file
$ cp 1MB_file 1MB_file_copied
$ dd bs=1024 count=1024 if=/dev/random of=1MB_file.2
$ sync
$ btrfs filesystem du *
     Total   Exclusive  Set shared  Filename
   1.00MiB       0.00B     1.00MiB  1MB_file
   1.00MiB     1.00MiB       0.00B  1MB_file2
   1.00MiB       0.00B     1.00MiB  1MB_file_copied
```

`1MB_file` と `1MB_file_copied` は共有されていることがわかる。

#### 明示的にコピーをしないとCoWによる共有はされない

ファイルの中身をチェックして共有しているわけではないため、
同じファイルだとしても別々の手段で取ってきたのならば共有されない。

```bash
$ cd mountpoint
$ wget https://live.staticflickr.com/65535/49568897633_1e4d1eb342_o_d.jpg --referer=https://live.staticflickr.com/65535/49568897633_1e4d1eb342_o_d.jpg
$ wget https://live.staticflickr.com/65535/49568897633_1e4d1eb342_o_d.jpg --referer=https://live.staticflickr.com/65535/49568897633_1e4d1eb342_o_d.jpg
$ sha1sum 49568897633_1e4d1eb342_o_d.jpg*
a673cc4dbd99f4e18c1bba82bd818c092d7cc237  49568897633_1e4d1eb342_o_d.jpg
a673cc4dbd99f4e18c1bba82bd818c092d7cc237  49568897633_1e4d1eb342_o_d.jpg.1
$ sync
$ btrfs filesystem du 49568897633_1e4d1eb342_o_d.jpg*
     Total   Exclusive  Set shared  Filename
   2.70MiB     2.70MiB       0.00B  49568897633_1e4d1eb342_o_d.jpg
   2.70MiB     2.70MiB       0.00B  49568897633_1e4d1eb342_o_d.jpg.1
```

#### CoWファイルシステムのCoWの弊害

新しいデータはディスクの空き容量に書き込んでから、新しいデータを参照するようにファイルのメタデータを変更する。
古いデータは参照を外すが該当領域はワイプはしないので残ったままになる。
（空き容量として扱われるので、あとで別のデータが書かれる可能性はある。）

```bash
$ fallocate -l 128M clean.img
$ mkfs.btrfs clean.img
$ mkdir mountpoint
$ sudo mount -t auto clean.img mountpoint
$ sudo chown $USER:$USER mountpoint

$ echo MySecretKey > mountpoint/hoge.txt
$ sync
$ strings clean.img | grep MySecretKey | sort | uniq
MySecretKey

$ echo hoge > mountpoint/hoge.txt
$ sync
$ strings clean.img | grep MySecretKey | sort | uniq
MySecretKey
```

#### 共有状態のファイルへの追記書き込み

追記書き込みすると追記していない所は共有されたままである。
5バイト追加であるのに関わらず4kBとなっているのは、
leaf block単位で処理されるときのサイズに対応していると思われる。

```bash
$ dd bs=1024 count=1024 if=/dev/random of=1MB_file
$ cp 1MB_file 1MB_file_copied
$ echo hoge >> 1MB_file_copied
$ sync
$ btrfs filesystem du *
     Total   Exclusive  Set shared  Filename
   1.00MiB       0.00B     1.00MiB  1MB_file
   1.00MiB     4.00KiB     1.00MiB  1MB_file_copied
```

#### 共有状態のファイルへの部分書き込み

10000バイトごとにファイルの中身を上書きするとどうなるか?

下記のようなディスク破壊用プログラムをつくった。

```rust
use std::fs::*;
use std::io::*;

fn main() {
    let path = std::env::args().nth(1).unwrap();
    let size = std::fs::metadata(&path).unwrap().len();

    let mut file = OpenOptions::new().write(true).open(&path).unwrap();
    let mut pos = 0;

    while pos < size {
        file.seek(SeekFrom::Start(pos)).unwrap();
        file.write(b"Crash!").unwrap();
        pos = pos + 10000;
    }
}
```

1MBのファイルに既述処理を施すと 1024 * 1024 / 1000 + 1 = 105 箇所書き込まれる。
105 * 4kB = 420kB 相当のところが書き換えられるのでそこが共有から外れる。

この420kBは `1MB_file_copied` で断片化領域の容量の和でもある。

```bash
$ cd mountpoint
$ dd bs=1024 count=1024 if=/dev/random of=1MB_file
$ cp 1MB_file 1MB_file_copied
$ sync
$ vi crash.rs
$ rustc crash.rs
$ ./crash 1MB_file_copied
$ strings 1MB_file_copied | grep Crash | wc -l
105
$ sync
$ btrfs filesystem du 1MB_file 1MB_file_copied
     Total   Exclusive  Set shared  Filename
   1.00MiB       0.00B     1.00MiB  1MB_file
   1.00MiB   420.00KiB   604.00KiB  1MB_file_copied
```

#### CoWの無効化

弊害を嫌う場合は、下記のようにして無効化しましょう

* ファイル単位での CoW を無効 `chattr +C file_nocow`
* ファイルシステム全体で CoW を無効。 "nodatacow" オプションを使ってマウント。

#### CoWまとめ

* ファイルを上書きしても上書きされないよ、一旦コピーしてから空き容量に書き込まれてから参照を張り直すよ
* ファイルのコピーをしても実態はコピーされないよ、共有されるよ
* コピーして共有されているファイルはファイル書き込み時に、空き容量によって書き込む仕組みの結果、共有が解かれるよ
* 弊害として断片化があるよ
* 嫌ならばファイル単位、またはファイルシステム全体で無効化出来るよ

### サブボリューム

フォルダのように使えるがマウントも出来る。
普通のフォルダの下にも置けちゃったりするなどかなり自由度は高い。
使い方はなんとなくでわかる。

* 作る
  ```bash
  $ sudo btrfs subvolume create mountpoint/subvolume
  ```
* 消す
  ```bash
  $ sudo btrfs subvolume delete mountpoint/subvolume
  ```
* 一覧
  ```bash
  $ sudo btrfs subvolume list mountpoint
  ```
* サブボリューム単位でのマウント
  ```bash
  $ sudo mount -t btrfs -o subvol=/subvolume devicefile mountpoint
  ```

※複製はスナップショットを使う。

### スナップショット

実態はサブボリュームのコピーである。
スナップショットって言っているのにデフォルトはコピー可である。

CoWのお陰でスナップショットを作る（サブボリュームのコピー）のは一瞬で終了する。

```bash
$ sudo btrfs subvolume snapshot mountpoint/subvolume mountpoint/subvolume_copied
```

普通の意味での readonly なスナップショットは、下記の通り `-r` を付ける。

```bash
$ sudo btrfs subvolume snapshot -r mountpoint/subvolume mountpoint/subvolume_copied
```

#### btrfsのスナップショットの特徴

* `btrfs subvolume snapshot` はサブボリュームのスナップショットとしてのコピーを作る
* スナップショットは単なるサブボリュームなので、普通に見たりコピーして取り出したりすることができる
* サブボリューム配下にあるサブボリュームはスナップショットにコピーされず空になる
  * サブボリュームをスナップショットによるコピーの除外に使う
* 既にあるサブボリュームに他のサブボリュームの内容に置き換えるのは単純な操作では不可能
  * `zfs rollback hoge@fuga` のような復元用コマンドはない

#### スナップショットの置き場所の検討

通常サブボリュームの下にスナップショットを作る構成が自然だが、
btrfs の仕組みだと復元作業が難しくなる。

 * fuga (subvolume)
   * files...
   * .snapshots/
     * snapshot1 (subvolume: snapshot)
     * snapshot2 (subvolume: snapshot)

対象サブボリュームの外側にスナップショットを作るのがよい。

 * fuga (subvolume)
   * files...
 * snapshots/ (subvolumeにしてもしなくとも、複数階層にしてもよい)
   * snapshot1 (subvolume: snapshot)
   * snapshot2 (subvolume: snapshot)

この構成の復元方法はおおよそ下記のようになる。

```bash
$ sudo mv fuga fuga_bak
$ sudo btrfs subvolume snapshot snapshots/snapshot1 fuga
$ sudo btrfs subvolume delete fuga_bak
```

これを踏まえての構成はたとえば

 * root (subvolume; マウント先=`/`)
 * home (subvolume; マウント先=`/home`)
 * log (subvolume; マウント先=`/var/log`)
 * snapshots/ (subvolume; マウント先=`/sys_snapshots` )
   * btrbk/
     * snapshots... (subvolume: snapshot)

ここで `/var/log` を別サブボリューム log にしている。
root スナップショットが復元されても、ログファイルが以前の状態に戻されることがないので、
トラブルシューティングが容易になる。

#### スナップショットの自動実行

まだデファクトはない。

単なるシェルスクリプト+cron(systemd timer)運用も多い。
そのぐらいでみんな満足しているということでもある。

Arch LinuxのWikiで推されていたのは`btrbk`。
[digint/btrbk: Tool for creating snapshots and remote backups of btrfs subvolumes](https://github.com/digint/btrbk)

##### btrbkの設定

スナップショットの他に別デバイスへのバックアップ(targetのところ)もできる。
別デバイスもbtrfsの場合はサブボリュームの差分送信機能を使うのでなかなか高速（すごい！）。

こんな感じの `/etc/btrbk/btrbk.conf` を書いておく。
なかなか意味が難しい。（よくわからない。雰囲気で使っている）

```
transaction_log		/var/log/btrbk.log

timestamp_format        long-iso

snapshot_preserve_min   2d
##snapshot_preserve      10d
snapshot_preserve      14d 6m

##target_preserve_min    18h
##target_preserve        48h 20d 6m
target_preserve_min    no
target_preserve        30d *m

volume /mnt/Root
  snapshot_dir snapshots/btrbk
  subvolume  root
    snapshot_create  always
    target /mnt/backup/snapshots/btrbk
```

##### btrbkのタイマー実行

systemd timer で定期実行する。
`btrbk.timer` で毎日トリガーをかけている。

```ini
[Unit]
Description=btrbk daily backup

[Timer]
OnCalendar=daily
AccuracySec=10min
Persistent=true

[Install]
WantedBy=multi-user.target
```

`btrbk.service`は単に`btrbk run`を呼んでいるだけ

```ini
[Unit]
Description=btrbk backup
Documentation=man:btrbk(1)

[Service]
Type=oneshot
ExecStart=/usr/sbin/btrbk run
```

#### スナップショットのまとめ

* サブボリュームは雰囲気でまじでどうとでもなるよ
* スナップショットは単なるサブボリュームのコピーだよ
* …のためいろいろと制約がでているよ。サブボリュームの構成はよく考えてる必要があるよ。
* スナップショットを取るプログラムはデファクトがまだないため混沌としているよ。
* `btrbk`は抜きん出ているけれども、なんとも難しいよ。でも雰囲気でなんとかなるよ。

### スクラブ

btrfs は明示的に洗わないといけない。定期的に汚れを落としましょう。

```bash
$ btrfs scrub start mountpoint
```

#### 単一ディスクだと耐障害性はやっぱりだめ?

破壊前のディスクを作る

```bash
$ fallocate -l 128M clean.img
$ mkfs.btrfs clean.img
$ mkdir mountpoint
$ sudo mount -t auto clean.img mountpoint
$ sudo chown $USER:$USER mountpoint
$ echo Hello > mountpoint/hello.txt
$ echo World > mountpoint/world.txt
$ sudo umount mountpoint
```

`World`を`WORLD`に書き換えた破壊済みファイルを作った。
チェックサムが合わないのでマウントができなくなった。

```bash
$ xxd -p -g 0 -c 134217728 clean.img | sed 's/576f726c64/574f524c44/ig' | xxd -p -r > crash.img
```

いろいろ試したが、破壊手順を元に復元する方法以外では、回復できなかった。
つまりこの破壊に対する復元をすることができなかった。

#### RAIDでミラーすると scrub で戦える

```bash
$ sudo modprobe brd rd_nr=2 rd_size=131072
$ sudo mkfs.btrfs /dev/ram0 /dev/ram1
$ mkdir mountpoint
$ sudo mount -t auto /dev/ram0 mountpoint
$ sudo chown $USER:$USER mountpoint
$ echo Hello > mountpoint/hello.txt
$ echo World > mountpoint/world.txt
$ sync
```

1台目を雑に完全に破壊した。
RAIDのお陰で読めているが、`/dev/ram0`は明らかに破壊されている

```bash
$ sudo dd if=/dev/zero of=/dev/ram0
$ cat mountpoint/hello.txt mountpoint/world.txt
Hello
World
$ sudo strings /dev/ram0 | grep Hello | sort | uniq | wc -l
0
```

scrubしてやると回復してくれる（再現性確保のため `/dev/zero` での上書き結果を載せているが、`/dev/random` だとエラー個数が変わる）。

```bash
$ sudo btrfs scrub start mountpoint
scrub started on mountpoint, fsid a86f9e3b-87e4-4731-a953-9a2be1b8f17b (pid=37388)
WARNING: errors detected during scrubbing, corrected
$ sudo btrfs scrub status mountpoint
UUID:             a86f9e3b-87e4-4731-a953-9a2be1b8f17b
Scrub started:    Sat Apr 24 18:19:07 2021
Status:           finished
Duration:         0:00:00
Total to scrub:   256.00KiB
Rate:             0.00B/s
Error summary:    csum=5
  Corrected:      5
  Uncorrectable:  0
  Unverified:     0
$ sync
$ sudo strings /dev/ram0 | grep Hello | sort | uniq | wc -l
0
```

#### スクラブまとめ

* 少し壊れたぐらいだと定期的な scrub で救えるかもしれない
* RAID だと定期的な scrub で救えるものがある
* 1台だと気休め? → やはり最悪オフライン（ポータブルHDDなど）でもよいのでバックアップは重要

### 参考文献

* [brd: メモリ上に作成するブロックデバイス](https://zenn.dev/satoru_takeuchi/articles/b8404632c2e02bc04dbf)
* Henson, Valerie (31 January 2008). [Chunkfs: Fast file system check and repair](http://mirror.linux.org.au/pub/linux.conf.au/2008/Thu/mel8-262.ogg). Melbourne, Australia. Event occurs at 18m 49s.
* [Btrfs - ArchWiki](https://wiki.archlinux.jp/index.php/Btrfs)

