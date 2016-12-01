require 'gitlab'
require 'json'

module Gitload
  module Sources
    class GitLab
      include Source

      def initialize options = {}
        ::Gitlab.configure do |c|
          c.endpoint = 'https://gitlab.com/api/v3'
          c.private_token = options.fetch :private_token, ENV['GITLOAD_GITLAB_TOKEN']
        end
      end

      def repos
        #data = ::Gitlab.projects.auto_paginate.collect &:to_h
        #File.open('tmp/gitlab.json', 'w'){ |f| f.write JSON.dump(data) }

        data = JSON.parse File.read('tmp/gitlab.json')

        data.collect{ |d| Repo.new d }
      end

      class Repo < Gitload::Repo
        def initialize api_data
          super :gitlab, api_data

          @name = api_data['path']
          @owner = api_data['namespace']['path']

          @clone_urls[:ssh] = api_data['ssh_url_to_repo']
          @clone_urls[:http] = api_data['http_url_to_repo']
        end
      end
    end
  end
end
