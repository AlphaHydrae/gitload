module Gitload
  module Repos
    class GitHub < Repo
      def initialize api_data
        super :github, api_data

        @name = api_data['name']
        @owner = api_data['owner']['login']
        @owner_type = api_data['owner']['type']

        @fork = api_data['fork']

        @clone_urls[:git] = api_data['git_url']
        @clone_urls[:ssh] = api_data['ssh_url']
        @clone_urls[:https] = api_data['clone_url']
      end
    end
  end
end
