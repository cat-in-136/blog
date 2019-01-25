---
layout: post
title: サイボウズLiveからredmineへの移行
date: '2019-01-26T01:16:21+09:00'
tags: redmine サイボウズ ruby データ移行
---
友人との情報共有のためにサイボウズLiveを使ってきたが、[告知のとおり2019年4月15日でサービスが終了][end-of-cybozu]することになった。

[end-of-cybozu]: https://live.cybozu.co.jp/about/20171024.html "サイボウズLiveサービス終了のお知らせ"

そこで、私たちが別途運用しているredmineに移行することにした。掲示板以外は使っていないか他のもので既に満足しているので、掲示板だけを移行することとした。redmineのフォーラム機能があるが、掲示板の内容をredmineのフォーラムに移行することとした。

## 移行先redmineの環境

移行先の環境は、おおよそ下記の通り

* web: Heroku
* db: ClearDB (mysql 5.6)
* storage: Dropbox

Heroku だとファイルが保存できないため、外部の何らかの AWS S3 といった Storage as a Service などを使って実現する必要がある。

今回の環境ではファイル容量がそんなに大きくないことと費用面の理由から dropbox を使用した。なお、dropbox を添付ファイルとして使うためには下記のプラグインを redmine にインストールする必要がある。本家では現在の API バージョンに対応していないので、フォークされたものを使う必要がある。

[bprotas/redmine_dropbox_attachments](https://github.com/bprotas/redmine_dropbox_attachments)

## 変換スクリプト

[@diffshare](https://github.com/diffshare) 氏によってたたき台となる Ruby でかかれた変換プログラムが作られた。

[https://gist.github.com/diffshare/f7899c48dca9988942c14d7126cefd29](https://gist.github.com/diffshare/f7899c48dca9988942c14d7126cefd29)

これは[サイボウズLive データ API](https://developer.cybozulive.com/doc/current/) を使用するためデベロッパ登録した上でアプリの登録（無料）が必要である。この登録作業は本題ではないので説明は割愛する。

これをもとに機能拡張などを行ったものを作成し、これを使って変換を実施する。

[https://gist.github.com/cat-in-136/a7ec320939f35812a64ac4e35e2a947b](https://gist.github.com/cat-in-136/a7ec320939f35812a64ac4e35e2a947b)

なお、このスクリプトは、下記のような redmine のフォルダで実行することを想定している。ruby on rails を知っていれば、後述の解説さえ読めば、容易に読解可能な程度のスクリプトであるため、本稿では使い方はわざわざ解説しない。

~~~terminal
$ cd path/to/redmine
$ DATABASE_URL='mysql2://user:mysecretpassword@localhost/redmine?reconnect=true'\
  LANG=en_US.UTF-8 RACK_ENV=production RAILS_ENV=production \
  RAILS_SERVE_STATIC_FILES=enabled SECRET_KEY_BASE=xxxxxxxx \
  MISC_CONFIG=miscconf.yaml ATTACH_CACHE_DIR=./ATTACH_CACHE_DIR \
  bundle exec rails r replace-from-cybozu-to-redmine.rb
~~~

注：後述の [#26030](https://www.redmine.org/issues/26030) のパッチを当てていない場合、この変換スクリプトで変換後のフォーラムでは不具合が起こるので、事前に当該パッチを当てておく（か将来出る redmine 4.1+ を使う）ようにすること。

### なぜCSVエクスポート機能を使わなかったのか?

簡単にいえば、扱いづらいの一言に限る。もちろん、単に手元に置いておくアーカイブとしては十分であろう。

しかし、添付ファイルとの紐付けがなかったり、いいね!情報がないなどの問題があり、API で取得する方がかえってやり易いということになった。

## 変換で問題となったこと

### 添付ファイル

掲示板などの情報から添付ファイル情報として `cbl:attachement` という要素があり、添付ファイルのIDは取得できる。サイボウズの API 仕様にあるように[ファイルダウンロードAPIは画像のみの対応](https://developer.cybozulive.com/doc/current/pub/fileDownload.html)である。実際に呼び出しても、**画像ファイル以外はエラーを吐く** という[挙動が報告](http://dotnsf.blog.jp/archives/1068218167.html)されているし、筆者の手元でもそうなった。

共有フォルダ（一括ダウンロード）機能は、画像以外の任意のファイルが保存できるが、コメントなどとの **対応性に関する情報は与えられない** 。また、同一ファイル名が ZIP 内で重複するのを防ぐため、ZIP 保存するとファイル名の末尾にランダムな文字列が付加される（このランダムな文字列はエクスポートするたびに異なるため、識別子としては使えない）。

というわけで、画像は API で、非画像は悩んだ末に簡易的なスクレイピング（単にクッキーを食わせてダウンロード）で取得した。

これとは別の話で、いずれの手段を使っても画像ファイルに関しては **オリジナルのファイルを取り出すことはできない** 。サイボウズ上の画像ファイルサイズが 1,145 kB と書いてあっても得られるダウンロードされるファイルは 197.0 kB といったような感じである。`optipng` などで非常に最適化をかけた画像については、逆にファイルサイズが肥大化していることもあるようだ。

### photo.jpg 問題

添付ファイルをダウンロードしてみたら、[旧モバイルアプリ](https://live.cybozu.co.jp/info/2016122101.html)で上げた画像ファイルは `photo.jpg` という名前のファイルになっているが、中身が JPEG ではなくて PNG になっていた。

なお、API でダウンロードしたとしても手動でダウンロードしたとしてもPNGファイルになっていたので、ファイル名 *（拡張子）が間違って保存されている* らしい。

解決策は対症療法だが、ファイルヘッダを見てPNGファイルかどうかを判断するようにした。この処理自体は[mimemagic] gemを使えば極めて簡単に実現できた。

[mimemagic]: https://rubygems.org/gems/mimemagic


### いいね!

Redmine にいいね!の機能は存在しない。そのためプラグインを入れることになるが、フォーラムにいいね!できるのは見当たらなかった。そこで下記の通り自作した。

[cat-in-136/redmine_hearts](https://github.com/cat-in-136/redmine_hearts)

ひとつ API 上でややこしいところがある。[good の API レスポンス](https://developer.cybozulive.com/doc/current/pub/good.html)において自分のいいね!と他人のいいね!は異なるかたちで表せられる。自分のは `cblGood:set` で、他人のは `cbl:who` だ。

~~~xml
    <cblGood:set>true</cblGood:set>
    <cbl:who valueString="佐藤 昇" id="1:1" />
    <cbl:who valueString="田中 美子" id="1:11" />
~~~

### 名寄せ

名寄せについては、簡単のため、YAML ファイルでサイボウズLiveのMember IDとredmineのIDの対応表を入れる実装とした。上のコマンドライン例に沿って言えば、miscconf.yaml に下記のように記入する。

~~~yaml
---
users:
  1:2 : jsmith
  1:3 : dlopper
  # "Member ID": "redmine login name"
~~~

なお、Member IDはAPIのアクセスの他に「プロフィールの詳細」を開いてURLを確認することでも得られる。
例えば、プロフィールの詳細のページのURLが `https://cybozulive.com/mpAddress/list?mid=1%3A2` ならば、
Member ID は `1:2` である。

### 発言番号とパーマリンク

Redmine のフォーラム機能にはカスタムフィールドがないので、付加的なメタデータをつけることはできない。

とはいえないのはないので過去のメッセージの参照において不便であるので、下記の通りとした。

* 発言番号は、苦肉の策だが subject 文字列に置換して移行
* パーマリンクも苦肉の策ながら、テキストメッセージの末尾に書いた（miscconf.yaml にて`import_source_to_content: true`を指定した場合）

これらは、あとは興味あるやつは頑張れ!というスタンスに基づく。使い勝手は悪いが、検索すれば見つけられるから後追いはできるようにはなるはずである。

### フォーラムのコメントの表示順番

redmineではデフォルトでは古→新の順番で表示され、またページあたりの表示項目数も固定である。
これは既に redmine 本家チケットの [#26030](https://www.redmine.org/issues/26030) であつかわれていて、
これによって、ユーザ設定で変更できるようになり、例えば、ユーザ設定で降順に変更できる（サイボウズ Live っぽく使える）。

入る予定が redmine 4.1 系になるらしい。だが、redmine 4 系への移行は、そもそもまだ開発段階のバージョンである上に、プラグインなど互換の都合上、慎重にならざるを得ないため今回は作業を見送ることとした。よって、手作業パッチをすることとした。

ところで、変換スクリプトで変換かけたフォーラムだと `message#1234` といったリンクの複数ページがうまく行かないが、
このパッチを当てることで実は正しく動くようになる。

`MessageController#show` にて `r=1234` というパラメータを渡すことで、pagination を対処する処理があったが、これは ID が過去から昇順で並んでいるのが前提でないと動かない。

~~~ ruby
    if params[:r] && page.nil?
      offset = @topic.children.where("#{Message.table_name}.id < ?", params[:r].to_i).count
      page = 1 + offset / REPLIES_PER_PAGE
    end
~~~

インポートスクリプトは、元のサイボウズLive の rss をそのままなめていっている挙動のせいでこれとは逆順に並んでいるため動作しなかった。

ところで[#26030](https://www.redmine.org/issues/26030)のパッチを投入した結果（あるいは redmine 4.1+）、ここのコードが下記のように、整列のところで `created_on` も見るようになっている。

~~~ ruby
    replies_order = User.current.wants_comments_in_reverse_order? ? 'DESC' : 'ASC'
    @replies = @topic.children.
      includes(:author, :attachments, {:board => :project}).
      reorder("#{Message.table_name}.created_on #{replies_order}, #{Message.table_name}.id #{replies_order}")

    if params[:r] && page.nil?
      offset = @replies.pluck(:id).index(params[:r].to_i)
      page = 1 + offset / per_page_option
    end
~~~

このお陰で、変換スクリプトで変換かけたフォーラムだと `message#1234` といったリンクの複数ページがうまく行かない不具合は結果的に解決できた。めでたしめでたし。（パッチをあたっていないときでも動作するような改造はやらないことにした。）

### emoji

これは mysql の環境の問題だが、絵文字を入力すると正しく表示されなくなった。

原因は、mysql を utf8mb4 ではなく utf8 で運用しているため5バイト(以上)文字は正しく表現できないのが原因だった。これは普通にredmineを使っていても注意が必要だ。

対策は、実態参照で変換することとすることとした（miscconf.yaml にて`escape_emoji: true`を指定した場合）。また実態参照にするかどうかの判断をemojiかどうかではなく5バイト(以上)文字かどうかにすることとした。新し目の絵文字をいちいちフォローするのは困難であるし、こうすると mysql の制限に合った処理かつ処理としても簡素である。

なお5バイト(以上)文字かどうかを判断する正規表現は下記の通りである:

~~~~ ruby
EMOJI_REGEX = /[^\u0000-\uFFFF]/
~~~~

なお、当然のことながら [cleardb を utf8mb で運用](http://xyk.hatenablog.com/entry/2015/01/14/143508)していたり、postgresql や sqlite で運用していたりする場合には、この現象は起こらないので気にしないで良い。

## 移行処理について

移行処理自体は `bundle exec rails run ./replace-from-cybozu-to-redmine.rb` で実行すればよいので、heroku 上で実行するために `heroku run bundle exec rails run ./replace-from-cybozu-to-redmine.rb` としてもよい。

…のであるが、実際にこれを動かすと1時間ちょっと経過したところで `heroku run` のプロセスが切られた。つまるところ1時間以内に実行が完了しないとNGのようであり、変換量が多いときにはNGのようである。愚直なバッチ処理なのでどうしてもこのスクリプトの実行には時間がかかる。またローカルでスクリプトを単純に動かすのも cleardb のアクセスのせいで時間がかかる。

そこで、一旦 cleardb のバックアップ用 sql ファイルをローカルのmysqlにインポートして、ローカルのmysql + リモートdropbox で変換を実施して、
あとで mysql をcleardbにインポートする策をとることにした。
一気にインポート/エクスポートする際は rails を介さないので良いので高速であり、またこの手法は安定している。

## 変換をあきらめた機能

その他、主要な「あきらめた機能」は下記の通り。

 * HTML形式の本文 (HTMLコードを取得する方法が API 上ない。scraping するのが面倒なのでやっていない)
 * 「`>xxx`」のリンク
 * メッセージ本文のインライン画像貼り付け（`[file:1]`を置換すればできるが面倒なのでやっていない）
 * トピックのカテゴリ (階層構造なしでフラットにトピックが並ぶ)
 * トピックに対する「★お気に入り」
 * アンケート機能
 * その他、掲示板以外のすべての機能

## おわりに

元ネタはさっさと出来たがいろいろな点でハマり、
片手間でやっているとはいえ、
予想よりも三か月ぐらいも余計に時間がかかった

また CSV では得られる情報が少ないのも驚いた。
Kintone 含む CSV ファイルからインポートする場合は、移行時に情報はかなり失われることになるのだろう。
それを上回るものができたのはずであるので、満足である。
