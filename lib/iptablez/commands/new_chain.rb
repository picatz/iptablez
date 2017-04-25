module Iptablez
  module Commands
    module NewChain
      # Move on Module
      include MoveOn

      CHAIN_ALREADY_EXITS_ERROR = 'iptables: Chain already exists.'
      KNOWN_ERRORS = [CHAIN_ALREADY_EXITS_ERROR] 

      # @api private
      # Determine a given error. Optionally a chain can be used to provide better context.
      private_class_method def self.determine_error(error:, chain: false)
        error.strip!
        if error == CHAIN_ALREADY_EXITS_ERROR 
          raise ChainAlreadyExistsError, "#{chain} already exist!"
        else
          raise error
        end
      end

      # Create a new chain of a given +name+, unless is already exists. This is the heart of the module.
      # @param name     [String]  Single chain +name+.
      # @param error    [Boolean] Determine if operations should raise/halt other possible operations with errors.
      # @param continue [Boolean] Determine if operations should continue despite errors.
      #
      # @example Basic Usage
      #   Iptablez::Commands::NewChain.chain(name: "dogs")
      #   # => true
      #   Iptablez::Commands::NewChain.chain(name: "dogs")
      #   # => false
      # @yield  [String, Boolean] The +name+ of the chain and +result+ of the operation if a block if given.
      # @return [String, Boolean] Key value pairing of the given chain +name+ and the +result+ of the operation.
      def self.chain(name:, error: false, continue: !error)
        name = name.to_s unless name.is_a? String
        _, e, s = Open3.capture3(Iptablez.bin_path, '-N', name.shellescape)
        e.strip! # remove new line 
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

      # Create each +name+ from a given array of +names+ unless the chain already exists.
      # @param names    [Array<String>] An array of chains to delete.
      # @param error    [Boolean]       Determine if operations should raise/halt other possible operations with errors.
      # @param continue [Boolean]       Determine if operations should continue despite errors.
      #
      # @example Basic Usage
      #   Iptablez::Commands::DeleteChain.chain(names: ["dogs", "whales"])
      #   # => {"dogs"=>false, "whales"=>true}
      #
      # @yield  [String, Boolean] The +name+ of the chain and +result+ of the operation if a block if given.
      # @return [Hash]            Key value pairing of each given chain +name+ and the +result+ of the operation.
      def self.chains(names:, error: false, continue: !error)
        results = {}
        names.each do |name|
          chain(name: name, continue: continue) do |name, result|
            yield [name, result] if block_given?
            results[name] = result
          end
        end
        results
      end
    end
  end
end
