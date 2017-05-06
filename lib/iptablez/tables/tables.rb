module Iptablez

  module Tables 
    
      DEFAULT = [ "filter", "nat", "mangle", "raw", "security" ].freeze
      
      def self.all
        DEFAULT 
      end

      def self.defaults
        DEFAULT.each { |table| yield table } if block_given?
        DEFAULT
      end
      
      def self.table?(name: false, names: false)
        if name
          return DEFAULT.include?(name)
        elsif names
          results = {}
          names.each do |name|
            results[name] = if table?(name: name)
                              true
                            else
                              false
                            end
            yield results[name] if block_given?
          end
          return results
        end
        false
      end
  
  end
end
