module Gitload
  class RepoChain
    extend Forwardable

    attr_reader :config
    attr_reader :repos

    def initialize config, repos = [], options = {}
      @config = config
      @repos = repos
      @rename = options[:rename]
    end

    def dup repos = nil
      RepoChain.new @config, repos || @repos, rename: @rename
    end

    def << repo
      @repos << repo
      self
    end

    def + repos
      repos = repos.repos while repos.respond_to? :repos
      @repos += repos
      self
    end

    alias_method :add, :+

    def by name, options = {}
      select{ |repo| repo.owner.downcase == name.to_s.downcase }
    end

    def on *sources
      select{ |repo| sources.include? repo.source }
    end

    alias_method :from, :on

    def named *criteria
      compiled_criteria = criteria.collect do |criterion|
        if criterion.kind_of? Regexp
          Proc.new{ |repo| repo.name.match criterion }
        else
          Proc.new{ |repo| repo.name.downcase == criterion.to_s.downcase }
        end
      end

      select do |repo|
        compiled_criteria.any? do |criterion|
          criterion.call repo
        end
      end
    end

    def forks
      select &:fork?
    end

    def select &block
      dup @repos.select(&block)
    end

    def reject &block
      dup @repos.reject(&block)
    end

    def rename pattern = nil, replacement = nil, &block
      @rename_block = block || Proc.new{ |name| name.sub pattern, replacement }
      self
    end

    def prefix prefix
      @prefix = prefix
      self
    end

    def clone
      clone_into
    end

    def clone_to dest = nil
      clone_repos :to, dest
    end

    def clone_into dest = nil
      clone_repos :into, dest
    end

    def_delegator :@config, :root

    private

    def clone_repos method, dest
      dest = if !dest
        File.expand_path(root.to_s)
      elsif root
        File.expand_path(dest.to_s, File.expand_path(root.to_s))
      else
        File.expand_path(dest.to_s)
      end

      puts dest
      dir = File.dirname dest
      #FileUtils.mkdir_p unless File.exists? dir

      @repos.each do |repo|

        repo_dest = if method == :into
          name = repo.name
          name = name.index(@prefix) == 0 ? name : "#{@prefix}#{name}" if @prefix
          name = @rename_block.call name if @rename_block
          File.join dest, name
        else
          dest
        end

        repo.clone_to repo_dest, @config.clone_options
      end
    end
  end
end
