require 'shellwords'

module Gitload
  module CommandLine
    class Command
      attr_reader :args

      def initialize *args
        @args = args
      end

      def execute
        system to_s
      end

      def to_s
        @args.collect{ |arg| Shellwords.shellescape arg.to_s }.join(' ')
      end
    end
  end
end
