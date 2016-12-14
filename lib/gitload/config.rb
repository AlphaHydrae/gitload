require 'fileutils'

module Gitload
  class Config
    attr_accessor :root
    attr_accessor :cache
    attr_accessor :clear_cache
    attr_accessor :dry_run
    attr_accessor :clone_url_type

    def initialize options = {}
      @root = options[:root]
      @cache = options.cache
      @clear_cache = options.clear_cache
      @dry_run = options.dry_run
      @clone_url_type = options[:clone_url_type]
    end

    def apply
      filename = File.expand_path '~/.gitload.rb'
      DSL.new(self).instance_eval File.read(filename), filename
    end

    def clone_options
      {
        dry_run: @dry_run,
        clone_url_type: @clone_url_type
      }
    end

    def load_or_cache_data relative_path
      delete relative_path if @clear_cache

      if @cache
        data = self.load relative_path
      end

      unless data
        data = yield
      end

      if @cache
        save relative_path, data
      end

      data
    end

    def load relative_path
      file = data_file relative_path
      File.exist?(file) ? JSON.parse(File.read(file)) : nil
    end

    def save relative_path, contents
      file = data_file relative_path
      FileUtils.mkdir_p File.dirname(file)
      File.open(file, 'w'){ |f| f.write JSON.dump(contents) }
    end

    def delete relative_path
      FileUtils.rm_f data_file(relative_path)
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

      def cache
        @config.cache = true
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
          Sources.sources[symbol].source *args.unshift(@config), &block
        else
          super symbol, *args, &block
        end
      end
    end

    private

    def data_file relative_path
      File.join data_dir, "#{relative_path}.json"
    end

    def data_dir
      File.join File.expand_path('~'), '.gitload'
    end
  end
end
