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

    def clone_url
      # TODO: allow clone url type to be configured
      @clone_urls[:ssh]
    end

    def clone_to dest, options = {}
      if @cloned && !options[:force]
        return
      elsif File.exists? dest
        puts Paint["#{dest} already exists", :green]
        return
      end

      url = Shellwords.shellescape clone_url
      dest = Shellwords.shellescape dest

      #puts
      #system "git clone #{url} #{dest}"
      puts "Clone #{url} to #{dest}"

      @cloned = true
    end
  end
end

Dir[File.join File.dirname(__FILE__), 'repos', '*.rb'].each{ |lib| require lib }
