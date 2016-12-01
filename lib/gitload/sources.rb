module Gitload
  module Sources
    def self.sources
      @sources ||= {}
    end

    module Source
      def self.included base
        base.extend ClassMethods
      end

      module ClassMethods
        def source options = {}
          new options
        end
      end
    end
  end
end

Dir[File.join File.dirname(__FILE__), File.basename(__FILE__, '.*'), '*.rb'].each{ |lib| require lib }

module Gitload::Sources
  constants.collect{ |c| const_get(c) }.select{ |c| Class === c && c.respond_to?(:source) }.each do |factory|
    factory_name = factory.respond_to?(:source_name) ? factory.source_name : factory.name.to_s.downcase.sub(/.*::/, '').to_sym
    sources[factory_name] = factory
  end
end
