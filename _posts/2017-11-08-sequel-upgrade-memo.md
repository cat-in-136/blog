---
layout: post
title: Sequel のバージョンアップデートに関するメモ
date: '2017-11-08T00:27:30+09:00'
tags: sequel ruby チラシの裏
---

とある private 運用している [padrino](http://padrinorb.com/) +
[sequel](http://sequel.jeremyevans.net/) rubygem を使ったアプリのバージョンアップをようやくやった。
v4.29 → v5.2 へのアップデートだったのだが、
一つ一つ[リリースノート](http://sequel.jeremyevans.net/documentation.html)を見ていって確認していったのだが
かなりの分量だった。
特に、v4.45 の deprecated features が多すぎだった。

---

ただ、実際に影響があったのは下記の2つの変更だけだった。

 1. The schema plugin is now deprecated. Switch to defining the schema before creating the model class using the Database schema methods. (ref. [4.45.0txt](http://sequel.jeremyevans.net/rdoc/files/doc/release_notes/4_45_0_txt.html))
    * schema plugin が廃止されたが、代替が指示されておらず意味を理解するまで時間がかかったが、
      結論は plugin の読み込み (`Sequel::Model.plugin(:schema)`) を消すだけだった。
    * スキーマを定義した後にモデルクラスを呼び出すという暗黙的なことになった。
    * 普通(?)、そういう使い方をすると思うので schema plugin は御役御免でよい。
 2. The `Dataset#and`, `exclude_where`, `interval`, and range methods are now deprecated. Undeprecated copies are now available in the new `sequel_4_dataset_methods` extension. (ref [4.48.0.txt](http://sequel.jeremyevans.net/rdoc/files/doc/release_notes/4_48_0_txt.html))
    * 微妙な例で示すと `Foo.where(:bar => 1).and(:baz => 2)` のような呼び出しの `and` が使えなくなった。
      * 単純な置き換えならば `Foo.where(:bar => 1).where(:baz => 2)` のように `where` をどんどんつなげていけば良い
      * なおこの例だと `Foo.where(:bar => 1, :baz => 2)` のようにも書けるのでリファクタした
        * ただ `:bar => 1` と `:baz => 2` の判定が別関数といった場合には、 `where` をつなげていくしかない
    * たぶんかなり古い?記述だったぽい
    * `or` とかは引き続き使える

