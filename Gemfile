source "https://rubygems.org"
# Add dependencies required to use your gem here.
# Example:
#   gem "activesupport", ">= 2.3.5"

gem 'paint', '~> 2.1'
gem 'commander', '~> 4.2'

gem 'octokit', '~> 4.6'
gem 'bitbucket_rest_api', '~> 0.1.7'
gem 'gitlab', '~> 4.10'

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  require 'pp' # https://github.com/fakefs/fakefs/issues/99
  gem 'rake', '~> 12.3'
  gem 'rspec', '~> 3.1'
  gem 'rspec-its', '~> 1.1'
  gem 'rspec-collection_matchers', '~> 1.1'
  gem 'fakefs', '~> 0.20.0', :require => 'fakefs/safe'
  gem 'jeweler', '~> 2.0'
  gem 'rake-version', '~> 1.0'
  gem 'simplecov', '~> 0.16.1'
  gem 'coveralls', '~> 0.8.22', require: false
end
