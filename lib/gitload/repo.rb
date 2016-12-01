require 'shellwords'

module Gitload
  class Repo
    attr_reader :source, :api_data, :name, :fork, :owner, :owner_type, :clone_urls

    def initialize source, api_data
      @source = source
      @api_data = api_data
      @cloned = false
      @clone_urls = {}
    end

    def fork?
      @fork
    end

    def clone_url options = {}
      @clone_urls[options[:clone_url_type] || :ssh]
    end

    def clone_to dest, options = {}
      if @cloned && !options[:force]
        return
      elsif File.exists? dest
        puts Paint["#{dest} already exists", :green]
        return
      end

      command = CommandLine::Command.new :git, :clone, clone_url(options), dest

      if true || options[:dry_run]
        puts Paint[command.to_s, :yellow]
      else
        #command.execute
      end

      @cloned = true
    end
  end
end
