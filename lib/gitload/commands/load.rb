require 'forwardable'

module Gitload
  module Commands
    class Load
      def initialize options = {}
        @config = Config.new options
      end

      def run
        @config.apply
      end
    end
  end
end
