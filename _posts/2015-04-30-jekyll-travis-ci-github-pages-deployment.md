---
layout: post
title: Jekyll ブログの Travis CI 使って Github Page への配備する方法のメモ
author: cat_in_136
tags:
- jekyll
- travis-ci
- "チラシの裏"
date: '2015-04-30T00:42:49+09:00'
---

まとめる気はない、単なる Travis CI のチラ裏メモ。

#### メモ

 * Travis-CI のビルド処理は[コンテナ型仮想化で動いて][travis-container]いる。
   * OS は ubuntu 。ただし、何か細工しているかもしれないが未調査。
   * よって `.travis.yml` は `Dockerfile` のノリで書く。
   * `apt-get` も使える。また、[aptアドオン][travis-apt]?の形でも使える。
 * ruby まわりの前提として rvm 、bundle 使用が無難
   * bundle 使わないですべて Apt で管理することもできるが、`Gemfile` をコミットした運用がよいだろう。
   * `rake` は `bundle exec rake` のように、ruby は `bundle` を介して使用しよう。 
 * Github のレポジトリに push したい場合は、何らかの秘密鍵を入れこむか、アクセストークンを使用する。
   * 鍵・アクセストークンともに公開すべきではないので、レポジトリに平文で格納しないこと。
     * [travis-encrypt](https://www.npmjs.com/package/travis-encrypt) を使えば暗号化されたテキストでやりとりできるので、センシティブな情報をやりとりするのにつかえる。
     * `travis encrypt -r ユーザ名/レポジトリ名 FOO=bar` とした上で `.travis.yml` に暗号化したテキストを書くのと、Travis の設定で環境変数 `FOO=bar` を非公開で設定するのは、動きに差はほどんどない。が、環境変数だったら後者の方がずっと楽。
       * 設定箇所への直リンは `https://travis-ci.org/ユーザ名/レポジトリ名/settings/env_vars`
   * アクセストークンを使って git にアクセスするは、[https://github.com/settings/tokens](https://github.com/settings/tokens) から Personal access token を生成し、`https://$GH_TOKEN@github.com/ユーザ名/レポジトリ名.git` から git clone すればよい。というか、これだけなのでアクセストークンの方がずっと簡単。
     * アクセストークンは環境変数としておいて上述の方法をつかってレポジトリに公開しないようにする。

#### やったことのメモ

アウトプット:

 * [.travis.yml](https://github.com/cat-in-136/blog/blob/master/.travis.yml)
 * [Rakefile](https://github.com/cat-in-136/blog/blob/master/Rakefile)


 1. Travis を Jekyll ソースのレポジトリと紐付ける。
 2. bundle を使用するように変更。`Gemfile` と `Gemfile.lock` を使用するように変更（厳密にはきちんと使っていなかったのできちんと書いた）。
 3. `Rakefile` に初期化コードも含めて本当にすべて動くようにした。(`setup` タスクの追加)
 4. `.travis.yml` を記載
    * LSI を使用するので、Apt で GSL ライブラリをインストールするようにした。
    * `bundle install` は特に書かなくても `language: ruby` になっていれば動くみたい。
    * `rake setup`、`rake generate` を呼び出す…のだが、`bundle exec rake setup` のように bundle を通して呼ぶようにする。
    * 環境変数のうちレポジトリに登録してしまってよいものを記載する。
 5. github アクセストークンを取得し、Travis CI の設定で環境変数 `GH_TOKEN` に設定する。 `.travis.yml` でそれを参照するべきところは `$GH_TOKEN` に置き換える。
 6. `git push` すると Travis が動いてくれるのでログを確認し、エラーがなくなるまで check & try する。

アクセストークンの隠蔽には少し苦労した。
ビルドログにて環境変数を設定する所はきちんと `$ export GH_TOKEN=[secure]` のように隠蔽してくれるのだが、
`git push` のところでどうしても `To https://XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX@github.com/cat-in-136/cat-in-136.github.io.git` のようなログが表示される。
しかも標準出力ではなく標準 *エラー* 出力に吐かれているので `> /dev/null` でも表示されてしまう。
というわけで、`git push` を呼び出す所は強引だが `bundle exec rake -q deploy 2>&1 | sed "s/${GH_TOKEN}/\${GH_TOKEN}/g"` とした。
（標準エラー出力を標準出力にぶちこんで、さらにそれを sed でテキスト置換）


#### 参考文献

 - [Jekyllでgit pushをフックしてGithubPageへ自動デプロイするようにした][toshimaru-autodeploy], Hack Your Design, 15 Nov 2013.
 - [OctopressとTravis CIを連携させてBlog生成を自動にする][pchw-octopress-travis], ぽっちぽちにしてやんよ, 27 Jun 2013.
 - [Travis CI: Using container-based infrastructure][travis-container]
 - [Travis CI: APT Sources and Packages][travis-apt]

[toshimaru-autodeploy]: http://blog.toshimaru.net/autodeploy-jekyll/ "Jekyllでgit pushをフックしてGithubPageへ自動デプロイするようにした"
[pchw-octopress-travis]: http://pchw.github.io/blog/2013/06/27/octopress-travis/ "OctopressとTravis CIを連携させてBlog生成を自動にする"
[travis-container]: http://docs.travis-ci.com/user/workers/container-based-infrastructure/ "Travis CI: Using container-based infrastructure"
[travis-apt]: http://docs.travis-ci.com/user/apt/ "Travis CI: APT Sources and Packages"

