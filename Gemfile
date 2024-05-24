# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in merginator.gemspec
gemspec

gem 'rake'

group :test do
  gem 'minitest', require: false
  gem 'rubocop', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-rake', require: false
  gem 'simplecov', require: false
end

group :development, :test do
  gem 'bundler-audit', require: false
  gem 'rbs', '~> 3.4', require: false
  gem 'steep', '~> 1.6', require: false
end
