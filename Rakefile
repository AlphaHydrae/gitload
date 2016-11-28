# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "gitload"
  gem.homepage = "https://github.com/AlphaHydrae/gitload"
  gem.license = "MIT"
  gem.summary = %Q{Gitload downloads your repositories.}
  gem.description = %Q{Gitload provides a DSL to easily clone all your repositories from GitHub and other providers.}
  gem.email = "git@alphahydrae.com"
  gem.authors = ["Simon Oulevay (Alpha Hydrae)"]
  gem.files = %x[git ls-files -- {bin,lib}].split("\n") + %w(Gemfile LICENSE.txt README.md VERSION)
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

Rake::TaskManager.class_eval do
  def remove_task(task_name)
    @tasks.delete(task_name.to_s)
  end
end

[ 'version', 'version:bump:major', 'version:bump:minor', 'version:bump:patch', 'version:write' ].each do |task|
  Rake.application.remove_task task
end

# version tasks
require 'rake-version'
RakeVersion::Tasks.new do |v|
  v.copy 'lib/gitload.rb'
end

require 'rspec/core/rake_task'
desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  #t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  # Put spec opts in a file named .rspec in root
end

task :default => :spec
