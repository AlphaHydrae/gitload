require File.join File.dirname(__FILE__), 'gitload'
require 'commander/import'

program :name, 'gitload'
program :version, Gitload::VERSION
program :description, 'Easily download all your GitHub repositories.'

global_option '-c', '--config PATH', 'Use a custom configuration file (defaults to ~/.gitload.rb)'

command :load do |c|
  c.syntax = 'gitload load'
  c.description = 'Downloads all configured repositories (default action)'
  c.action do |args,options|
    Gitload::Commands::Load.new(options).run
  end
end

default_command :load
