require 'shellwords'

module Gitload
  class Repo
    attr_reader :clone_urls
    attr_accessor :source, :api_data, :name, :fork, :owner, :owner_type, :cloned

    def initialize source, api_data
      @source = source
      @api_data = api_data
      @cloned = false
      @clone_urls = {}
    end

    def cloned?
      !!@cloned
    end

    def fork?
      !!@fork
    end

    def clone_url type = nil
      @clone_urls[type || :http]
    end

    def clone_to dest, options = {}
      if @cloned && !options[:force]
        return
      elsif File.exists? dest
        @cloned = true
        CommandLine.print "#{dest} already exists", color: :green
        return
      end

      command = [ :git, :clone, clone_url(options[:clone_url_type]), dest ]

      if options[:dry_run]
        CommandLine.print CommandLine.escape(command), color: :yellow
      else
        CommandLine.execute command
      end

      @cloned = true
    end
  end
end
