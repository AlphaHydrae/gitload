require 'gitlab'
require 'json'

module Gitload
  module Sources
    class GitLab
      include Source

      def initialize config, options = {}
        @config = config

        ::Gitlab.configure do |c|
          c.endpoint = 'https://gitlab.com/api/v4'
          c.private_token = options.fetch :private_token, ENV['GITLOAD_GITLAB_TOKEN']
        end
      end

      def repos

        puts 'Loading GitLab projects...'
        data = @config.load_or_cache_data 'gitlab' do

          projects = []

          Gitlab.projects(membership: true, per_page: 100).auto_paginate do |project|
            projects << project.to_h
          end

          Utils.stringify_keys(projects)
        end

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
