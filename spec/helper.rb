require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'simplecov'
require 'coveralls'
Coveralls.wear!

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
])

RSpec.configure do |config|

  config.before :each, fakefs: true do
    FakeFS.activate!
  end

  config.after :each, fakefs: true do
    FakeFS.deactivate!
    FakeFS::FileSystem.clear
  end
end

require 'rspec'
require 'rspec/its'
require 'rspec/collection_matchers'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each{ |f| require f }

require 'fakefs/spec_helpers'

require 'gitload'
require 'ostruct'
