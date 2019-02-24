source "https://rubygems.org"
ruby RUBY_VERSION

# Hello! This is where you manage which Jekyll version is used to run.
# When you want to use a different version, change it below, save the
# file and run `bundle install`. Run Jekyll with `bundle exec`, like so:
#
#     bundle exec jekyll serve
#
# This will help ensure the proper Jekyll version is running.
# Happy Jekylling!
gem "jekyll", "~> 3.8.5"

# If you have any plugins, put them here!
group :jekyll_plugins do
  #gem "jekyll-feed", "~> 0.6"
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
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.0" if Gem.win_platform?

