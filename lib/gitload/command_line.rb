require 'shellwords'

module Gitload
  module CommandLine
    class << self
      def execute *args
        system escape(args.flatten)
      end

      def escape args
        args.collect{ |arg| Shellwords.shellescape arg.to_s }.join(' ')
      end

      def print message, options = {}
        if options[:color]
          paint_args = options[:color].kind_of?(Array) ? options[:color] : [ options[:color] ]
          paint_args.unshift message
          message = Paint[*paint_args]
        end

        if options.fetch :new_line, true
          puts message
        else
          print message
        end
      end
    end
  end
end
