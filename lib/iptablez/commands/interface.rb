module Iptablez
  module Commands
    module Interface 
    
      def self.delete_chain(name: false, all: false)
        if name
          DeleteChain.chain(name: name)
        elsif all
          DeleteChain.all
        else
          raise "No chain name/all specified."
        end
      end

      def self.flush(chain: false, all: true)
        if chain
          Flush.chain(name: chain)
        elsif all
          Flush.all
        else
          raise "No chain/all specified."
        end
      end  
   
      def self.list(chain: false, all: true, number: false) 
        if chain && ! number
          List.chain(name: chain)  
        elsif number && chain
          List.number(chain: chain, number: number)
        elsif all
          List.all 
        else
          raise "No chain/number/all specified."
        end 
      end

      def self.new_chain(name:) 
        NewChain.chain(name: name)
      end

      def self.policy(target:, chain: false, all: true)
        if chain && target
          Policy.chain(name: chain, target: target)
        elsif all && target
          Policy.all(target: target)
        else
          raise "No chain/target/all specified."
        end
      end

      def self.rename_chain(from:, to:)
        if from && to
          RenameChain.chain(from: from, to: to)
        else
          raise "No from/to specified."
        end
      end

      def self.version(full: false)
        if full
          Version.full
        else
          Version.number
        end
      end

      def self.zero(all: true, chain: false)
        if chain
          Zero.chain(name: chain)
        elsif all 
          Zero.all
        else
          raise "No all/chain specified."
        end
      end

    end
  end
end
