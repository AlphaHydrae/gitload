module Gitload
  class RepoList
    attr_reader :repos
    attr_accessor :root

    def initialize repos = [], options = {}
      @repos = repos
      @root = options[:root]
      @rename = options[:rename]
    end

    def << repo
      @repos << repo
      self
    end

    def + repos
      @repos += repos
      self
    end

    def from name, options = {}
      select do |repo|
        repo.owner.downcase == name.to_s.downcase && options.fetch(:on, repo.source) == repo.source
      end
    end

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
      RepoList.new @repos.select(&block), options
    end

    def rename pattern = nil, replacement = nil, &block
      @rename_block = block || Proc.new{ |name| name.sub pattern, replacement }
      self
    end

    def clone
      clone_into
    end

    def clone_to dest = nil
      clone_repo :to, dest
    end

    def clone_into dest = nil
      clone_repo :into, dest
    end

    private

    def options
      {
        root: @root,
        rename: @rename
      }
    end

    def clone_repo method, dest
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
          name = @rename_block.call name if @rename_block
          File.join dest, name
        else
          dest
        end

        repo.clone_to repo_dest
      end
    end
  end
end
