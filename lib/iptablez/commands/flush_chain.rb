module Iptablez
  module Commands
    module FlushChain
      # Move on Module
      include MoveOn

      NO_CHAIN_MATCH_ERROR = 'iptables: No chain/target/match by that name.'.freeze
      KNOWN_ERRORS = [NO_CHAIN_MATCH_ERROR].freeze
     
      # Flush all of the possible `iptables` chains.
      # @example Basic Usage
      #   Iptablez::Commands::Flush.all
      #   # => {"INPUT"=>true, "FORWARD"=>true, "OUTPUT"=>true}
      # @example Basic Usage with a Block
      #   Iptablez::Commands::Flush.all do |name, result|
      #     puts "#{name} flushed!" if result
      #   end
      def self.all(names: Iptablez::Chains.all, error: false, continue: !error) 
        chains(names: names, continue: continue) do |name, result|
          yield [name, result] if block_given?
        end
      end

      # Flush the rules for a chain of a given `name`. This is the heart of this modules.
      # @todo Document params.
      # @example Basic Usage
      #   Iptablez::Commands::Flush.chain(name: "INPUT")
      #   # => true
      #   Iptablez::Commands::Flush.chain(name: "cats") # not a real chain
      #   # => false
      # @example Basic Usage with a Block
      #   Iptablez::Commands::Flush.chain(name: "INPUT") do |name, result|
      #     puts "#{name} flushed" if result
      #   end
      def self.chain(name:, error: false, continue: !error)
        _, e, s = Open3.capture3(Iptablez.bin_path, '-F', name)      
        e.strip!
        if s.success?
          yield [name, true] if block_given?
          return true
        elsif MoveOn.continue?(continue: continue, message: e, known_errors: KNOWN_ERRORS)
          yield [name, false] if block_given?
          return false
        else
          determine_error(chain: name, error: e)
        end
      end

      # Flush the rules for multiple chains of their given `names`.
      # @todo Document params.
      # @example Basic Usage
      #   Iptablez::Commands::Flush.chains(names: ["dogs", "cats"])
      #   # => {"dogs"=>true, "cats"=>false}
      # @example Basic Usage with a Block
      #   Iptablez::Commands::Flush.chains(names: ["dogs", "cats"]) do |name, result|
      #     puts "#{name} flushed" if result
      #   end
      def self.chains(names:, error: false, continue: !error)
        results = {}
        names.each do |name|
          results[name] = chain(name: name, continue: continue) do |name, result|
            yield [name, result] if block_given?
          end
        end
        results
      end


    end
  end
end
