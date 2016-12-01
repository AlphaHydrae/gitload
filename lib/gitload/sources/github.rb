require 'json'
require 'octokit'

module Gitload
  module Sources
    class GitHub
      include Source

      def initialize options = {}
        ::Octokit.configure do |c|
          c.auto_paginate = true
          c.access_token = options.fetch :access_token, ENV['GITLOAD_GITHUB_TOKEN']
        end
      end

      def repos
        #data = ::Octokit.repositories.collect &:to_attrs
        #File.open('tmp/github.json', 'w'){ |f| f.write JSON.dump(data) }

        data = JSON.parse File.read('tmp/github.json')

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
