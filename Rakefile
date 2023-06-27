# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/test_*.rb']
end

require 'rubocop/rake_task'

RuboCop::RakeTask.new

namespace :test do
  desc 'Run all tests: tests, rubocop, and steep'
  task :all do
    Rake::Task['test'].execute
    Rake::Task['rubocop'].execute
    Rake::Task['test:steep:check'].execute
  end

  namespace :steep do
    desc 'Run steep check'
    task :check do
      sh 'steep', 'check'
    end
  end
end

task default: %i[test rubocop test:steep:check]
