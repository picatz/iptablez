module Iptablez

  module Tables
  
    DEFAULT = [ 'filter', 'nat', 'mangle', 'raw', 'security' ].freeze
  
    def self.defaults
      return DEFAULT unless block_given?
      DEFAULT.each { |table| yield table }
    end
  
  end

end
