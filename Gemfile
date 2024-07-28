source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

gem "rails", "~> 7.0.8", ">= 7.0.8.1"
gem "sprockets-rails"
gem "sqlite3", "~> 1.4"
gem "puma", "~> 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "redis", "~> 4.0"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false
gem "sassc-rails"
gem "bootstrap"
gem "jquery-rails"
gem "ruby-openai"
gem "dotenv-rails", groups: [:development, :test]
gem 'rubocop', require: false
gem 'rubocop-rails', require: false
gem 'rubocop-rspec', require: false
gem 'rubocop-capybara', require: false



group :development, :test do
  gem "rspec-rails"
  gem "vcr"
  gem "webmock"
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'brakeman'
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
