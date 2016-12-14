module Gitload
  module Utils
    def self.stringify_keys object
      if object.kind_of? Hash
        object.inject({}) do |memo,(key,value)|
          memo[key.to_s] = stringify_keys value
          memo
        end
      elsif object.kind_of? Array
        object.collect do |value|
          stringify_keys value
        end
      else
        object
      end
    end
  end
end
