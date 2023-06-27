# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in merginator.gemspec
gemspec

gem 'rake'

group :development, :test do
  gem 'rubocop', require: false
  gem 'rubocop-rake', require: false
  gem 'steep', require: false
end

group :test do
  gem 'minitest'
  gem 'rubocop-minitest', require: false
  gem 'simplecov', require: false
end
