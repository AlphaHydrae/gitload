require 'json'
require 'bitbucket_rest_api'
require 'octokit'

module Gitload
  module Commands
    class Load
      def initialize options = {}
        @repos = RepoList.new
      end

      def run
        filename = File.expand_path '~/.gitload.rb'
        LoadDsl.new(@repos).instance_eval File.read(filename), filename
      end
    end

    class LoadDsl
      attr_reader :repos

      def initialize repos
        @repos = repos
      end

      def bitbucket
        #bitbucket = BitBucket.new basic_auth: "#{ENV['GITLOAD_BITBUCKET_USER']}:#{ENV['GITLOAD_BITBUCKET_TOKEN']}"
        #data = bitbucket.repos.list
        #File.open('tmp/bitbucket.json', 'w'){ |f| f.write JSON.dump(data) }

        data = JSON.parse File.read('tmp/bitbucket.json')
        data = data.select{ |repo| repo['scm'] == 'git' }

        repos = data.collect{ |d| Repos::Bitbucket.new d }
        @repos += repos

        repos
      end

      def github
=begin
        Octokit.configure do |c|
          c.access_token = ENV['GITLOAD_GITHUB_TOKEN']
          c.auto_paginate = true
        end

        data = Octokit.repositories.collect &:to_attrs
        File.open('tmp/github.json', 'w'){ |f| f.write JSON.dump(data) }
=end
        data = JSON.parse File.read('tmp/github.json')

        repos = data.collect{ |d| Repos::GitHub.new d }
        @repos += repos

        repos
      end

      def root dest

        previous_root = @repos.root
        @repos.root = dest

        if block_given?
          yield @repos
          @repos.root = previous_root
        end
      end
    end
  end
end
