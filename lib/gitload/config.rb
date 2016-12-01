module Gitload
  class Config
    attr_accessor :root
    attr_accessor :clone_url_type

    def initialize options = {}
      @root = options[:root]
      @clone_url_type = options[:clone_url_type]
    end

    def apply
      filename = File.expand_path '~/.gitload.rb'
      DSL.new(self).instance_eval File.read(filename), filename
    end

    def clone_options
      {
        clone_url_type: @clone_url_type
      }
    end

    class DSL
      extend Forwardable

      attr_reader :repos

      def initialize config
        @config = config
        @repos = RepoChain.new @config
      end

      def chain repos = [], options = {}
        RepoChain.new @config, repos, options
      end

      def root dest, &block

        previous_root = @config.root
        @config.root = dest

        if block
          instance_eval &block
          @config.root = previous_root
        end
      end

      def clone_url_type type, &block

        previous_type = @config.clone_url_type
        @config.clone_url_type = type

        if block
          instance_eval &block
          @config.clone_url_type = previous_type
        end
      end

      alias_method :into, :root

      def_delegator :@repos, :add

      def method_missing symbol, *args, &block
        if Sources.sources.key? symbol
          Sources.sources[symbol].source *args, &block
        else
          super symbol, *args, &block
        end
      end
    end
  end
end
