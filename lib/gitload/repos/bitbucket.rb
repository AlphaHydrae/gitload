module Gitload
  module Repos
    class Bitbucket < Repo
      def initialize api_data
        super :bitbucket, api_data

        @name = api_data['slug']
        @owner = api_data['owner']

        @fork = api_data['is_fork']

        @clone_urls[:ssh] = "git@bitbucket.org:#{@owner}/#{@name}.git"
        @clone_urls[:https] = "https://AlphaHydrae@bitbucket.org/#{@owner}/#{@name}.git"
      end
    end
  end
end
