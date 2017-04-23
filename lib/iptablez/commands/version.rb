module Iptablez
  module Commands
    # @todo
    module Version 
      def self.number 
        o, e, s = Open3.capture3(Iptablez.bin_path, '--version')      
        return o.strip.split[1].gsub('v','') if s.success?
        raise e 
      end
      
      def self.full
        o, e, s = Open3.capture3(Iptablez.bin_path, '--version')      
        return o.strip if s.success?
        raise e 
      end
    end
  end
end
