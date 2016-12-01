require 'bitbucket_rest_api'
require 'json'

module Gitload
  module Sources
    class Bitbucket
      include Source

      def initialize options = {}
        user = options.fetch :user, ENV['GITLOAD_BITBUCKET_USER']
        password = options.fetch :password, ENV['GITLOAD_BITBUCKET_TOKEN']
        @bitbucket_api = ::BitBucket.new basic_auth: "#{user}:#{password}"
      end

      def repos
        #data = @bitbucket_api.repos.list
        #File.open('tmp/bitbucket.json', 'w'){ |f| f.write JSON.dump(data) }

        data = JSON.parse File.read('tmp/bitbucket.json')
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
