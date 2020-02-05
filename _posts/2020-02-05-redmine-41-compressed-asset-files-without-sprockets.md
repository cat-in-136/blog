---
layout: post
title: Redmine 4.1 でアセットファイルの圧縮をするように頑張った顛末メモ
date: '2020-02-05T22:00:47+09:00'
tags:
- redmine
- チラシの裏
- httpd
---

Redmine 4.1 では下記のとおり sprockets が削除された。

 * [Defect #32223: Disable sprockets to avoid Sprockets::Railtie::ManifestNeededError raised by sprockets 4.0.0 - Redmine](https://www.redmine.org/issues/32223)
 * [Exception without manifest.js in 4.0.0 · Issue #643 · rails/sprockets](https://github.com/rails/sprockets/issues/643)

sprockets によるアセットの gzip 自動圧縮がされなくなった。
gzipアセットはデータ転送の削減するが、この恩恵が得られなくなる。
すなわちギガを消費するようになってしまう。

であるならば、 sprockets を再導入すればいい訳だが、
消された理由からは、sprockets の再導入は難しそうであった。

経緯を確認してみると、
sprockets 4.0.0 がインストールされると `Sprockets::Railtie::ManifestNeededError` が発生しRedmineが起動しない問題に対して、sprockets 3.7 系で固定化する暫定対処をしていた。
（[Defect #32300: Don't use sprockets 4.0.0 in order to avoid Sprockets::Railtie::ManifestNeededError - Redmine](https://www.redmine.org/issues/32300)）
これに対する正式対応が sprockets を使わなくするということになった模様だ。
なお、 sprockets を自力で有効する場合についての情報は不明であった。
もっとも sprockets はかなり複雑であり、ただ単に gzip したいという要求にはそもそも向かない。

> > I don't know if disabling/removing sprockets this way in the Redmine core makes enabling of the Rails asset pipeline locally more difficult than it currently is?
>
> Sorry, I don't know.

ところで、gzip アセットを配信する仕組みを調べてみると、[actionpack の `action_dispatch/middleware/static.rb` の `ActionDispatch::FileHandler` で処理されている](https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/middleware/static.rb)ことがわかるが。
興味深いことに、ただ単に precompiled gzip ファイルさえ置いてしまえば動作するようである。

というわけでバッチでも何でも良いので、public フォルダ配下のファイルについて gzip ファイルを作成してしまえば良い。

ただsprocketsのこの仕組みはversion 3.5頃でもコロコロと変わったことがあるらしく、[その頃の先人たちの記録](https://stackoverflow.com/questions/29700369/missing-gzip-version-of-css-and-js-assets)を見ると rake task で対処している例が見つかった。

ところで、heroku でもアセットの precompile を行ってくれるのだが、
sprockets が無くとも `assets:precompile` task を捏造さえすれば Heroku の Slug Compiler (Google Cloud Build の heroku 版だと思えば良い) の [compile phase](https://devcenter.heroku.com/articles/ruby-support#rails-5-x-applications-compile-phase) でビルドが動くことが判明した。

> As a final task in the compilation phase, the `assets:precompile` Rake task is executed if you have a `assets:precompile` Rake task defined, and don’t have a `public/assets/manifest-*.json` file.

…という経緯を経て、結局のところ、
gzip 実行する `assets:precompile` を作れば汎用的な解決策になるだろうということで、
結果下記のようなタスクを追加するに至った。


``` ruby
namespace :assets do
  desc "Gzip all the HTML/CSS/JS files in the public folder"
  task :precompile do
    require 'zlib'

    begin
      Rake::Task['redmine:plugins:assets'].invoke
    rescue => error
      puts "failed to execute redmine:plugins:assets task: #{error}"
    end

    Dir.glob(File.join(Rails.root, 'public', '**', '*.{html,css,js}')).each do |path|
      File.delete("#{path}.gz") if File.exist?("#{path}.gz")
      Zlib::GzipWriter.open("#{path}.gz", Zlib::BEST_COMPRESSION) do |gz|
        gz.mtime = File.mtime(path)
        gz.orig_name = File.basename(path)
        gz.puts File.open(path, 'rb') {|f| f.read }
      end
    end
  end
```

ポイントは `redmine:plugins:assets` タスクを事前に実行しておいて、
プラグインのアセットファイルも `public` フォルダにコピーをしてから、
gzip 処理を施すことだ。そうしないとプラグインのアセットファイルが圧縮されない。

なお zopfli などを使えばもっと圧縮率を上げれるだろうがそこまではやっていない。
そこまでやるなら brotli 使うぐらいの対処を施したいものである。
