source "https://rubygems.org"
ruby RUBY_VERSION

gem "jekyll", "~>3.8"

# If you have any plugins, put them here!
group :jekyll_plugins do
  gem "jekyll-paginate-v2"
  gem "jekyll-archives"
end

gem "imagesize"

group :lsi do
  gem 'rb-gsl', '~> 1.16'
  gem 'classifier-reborn'
end

gem "rake"
gem "term-ansicolor"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'wdm', '>= 0.1.1' if Gem.win_platform?

