# encoding: UTF-8
require 'paint'

module Gitload
  VERSION = '1.0.1'
end

Dir[File.join File.dirname(__FILE__), File.basename(__FILE__, '.*'), '*.rb'].each{ |lib| require lib }
