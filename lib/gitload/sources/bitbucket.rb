require 'bitbucket_rest_api'
require 'json'

module Gitload
  module Sources
    class Bitbucket
      include Source

      def initialize config, options = {}

        @config = config

        user = options.fetch :user, ENV['GITLOAD_BITBUCKET_USER']
        password = options.fetch :password, ENV['GITLOAD_BITBUCKET_TOKEN']
        @bitbucket_api = ::BitBucket.new basic_auth: "#{user}:#{password}"
      end

      def repos

        data = @config.load_or_cache_data 'bitbucket' do
          Utils.stringify_keys(@bitbucket_api.repos.list)
        end

        data = data.select{ |repo| repo['scm'] == 'git' }

        data.collect{ |d| Repo.new d }
      end

      class Repo < Gitload::Repo
        def initialize api_data
          super :bitbucket, api_data

          @name = api_data['slug']
          @owner = api_data['owner']

          @fork = api_data['is_fork']

          @clone_urls[:ssh] = "git@bitbucket.org:#{@owner}/#{@name}.git"
          @clone_urls[:http] = "https://AlphaHydrae@bitbucket.org/#{@owner}/#{@name}.git"
        end
      end
    end
  end
end
