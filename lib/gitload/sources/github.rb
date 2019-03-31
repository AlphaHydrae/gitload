require 'json'
require 'octokit'

module Gitload
  module Sources
    class GitHub
      include Source

      def initialize config, options = {}
        @config = config

        ::Octokit.configure do |c|
          c.auto_paginate = true
          c.access_token = options.fetch :access_token, ENV['GITLOAD_GITHUB_TOKEN']
        end
      end

      def repos

        puts 'Loading GitHub projects...'
        data = @config.load_or_cache_data 'github' do
          Utils.stringify_keys ::Octokit.repositories.collect(&:to_attrs)
        end

        data.collect{ |d| Repo.new d }
      end

      class Repo < Gitload::Repo
        def initialize api_data
          super :github, api_data

          @name = api_data['name']
          @owner = api_data['owner']['login']
          @owner_type = api_data['owner']['type']

          @fork = api_data['fork']

          @clone_urls[:git] = api_data['git_url']
          @clone_urls[:ssh] = api_data['ssh_url']
          @clone_urls[:http] = api_data['clone_url']
        end
      end
    end
  end
end
