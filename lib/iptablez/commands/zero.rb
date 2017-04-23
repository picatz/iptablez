module Iptablez
  module Commands
    module Zero 
      def self.all
        o, e, s = Open3.capture3(Iptablez.bin_path, '-Z')      
        return true if s.success?
        raise e 
      end

      def self.chain(name:)
        o, e, s = Open3.capture3(Iptablez.bin_path, '-Z', name)      
        return true if s.success?
        raise e 
      end
    end
  end
end
