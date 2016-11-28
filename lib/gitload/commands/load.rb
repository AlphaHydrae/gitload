require 'octokit'

module Gitload
  module Commands
    class Load
      def initialize options = {}
      end

      def run

        Octokit.configure do |c|
          c.access_token = ENV['GITLOAD_TOKEN']
          c.auto_paginate = true
        end

        repos = Octokit.repositories ENV['GITLOAD_GITHUB_USER']

        puts repos.collect{ |r| r.to_attrs[:name] }
      end
    end
  end
end
