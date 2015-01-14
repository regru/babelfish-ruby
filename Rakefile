require 'rake'

APP_ROOT = File.dirname(__FILE__).freeze

require 'bundler/setup'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

RSpec::Core::RakeTask.new(:rcov) do |t|
  t.rcov = true
  t.ruby_opts = '-w'
  t.rcov_opts = %q[-Ilib --exclude "spec/*,gems/*"]
end

task :default => :spec

require 'yard'

YARD::Rake::YardocTask.new do |yard|
  version = File.exists?('VERSION') ? IO.read('VERSION') : ""
  yard.options << "--title='git-commit-notifier #{version}'"
end
