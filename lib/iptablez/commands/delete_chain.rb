module Iptablez
  module Commands
    # The namespace to describe the `iptables` `-X` argument to delete a chain.
    # @author Kent 'picat' Gruber
    module DeleteChain
      # Move on Module
      include MoveOn

      NO_CHAIN_MATCH_ERROR = 'iptables: No chain/target/match by that name.'.freeze
      CHAIN_NOT_EMPTY      = 'iptables: Directory not empty.'.freeze

      KNOWN_ERRORS = [NO_CHAIN_MATCH_ERROR, CHAIN_NOT_EMPTY].freeze

      # @api private
      # Determine a given error. Optionally a chain can be used to provide better context.
      private_class_method def self.determine_error(error:, chain: false)
        if error == NO_CHAIN_MATCH_ERROR
          raise ChainExistenceError, "#{chain} doesn't exist!"
        elsif
          raise ChainNotEmpty, "#{chain} is not empty! Will probably need to flush (-F) it to delete it!" 
        else
          raise error
        end
      end

      # Delete all of the user defined chains.
      #
      # @example Basic Usage
      #   Iptablez::Commands::DeleteChain.all
      #   # => {"dogs"=>true}
      #
      # @example Basic Usage with a Block
      #   Iptablez::Commands::DeleteChain.all do |name, result|
      #     puts "#{name} has been deleted." if result # true
      #   end
      #
      # @yield Each chain name and boolean if it has been successfully deleted.
      # @return [Hash] Key value pairing of each user defined chain and boolean if it has been successfully deleted.
      def self.all(error: false, continue: !error)
        results = {}
        chains(names: Iptablez::Chains.user_defined, continue: continue, fly_by: fly_by) do |name, result|
          yield [name, result] if block_given?
          results[name] = result
        end
        return false if results.empty?
        results
      end

      # Delete a chain of a given +name+. This is the heart of this module.
      # @param name     [String]  Single chain +name+.
      # @param error    [Boolean] Determine if operations should raise/halt other possible operations with errors.
      # @param continue [Boolean] Determine if operations should continue despite errors.
      #
      # @example Basic Usage
      #   Iptablez::Commands::DeleteChain.chain(name: "dogs")
      #   # => false
      #   Iptablez::Commands::DeleteChain.chain(name: "cats")
      #   # => true
      # @example Basic Usage with a Block
      #   Iptablez::Commands::DeleteChain.chain(name: "dogs") do |name, result|
      #     puts "#{name} deleted!" if result
      #   end
      #
      # @yield  [String, Boolean] The +name+ of the chain and +result+ of the operation if a block if given.
      # @return [Boolean]         The result of the operation.
      #
      # @raise An error will be raised if the +error+ or +continue+ keywords are +true+ and the operation fails.
      def self.chain(name:, error: false, continue: !error)
        name = name.to_s unless name.is_a? String
        _, e, s = Open3.capture3(Iptablez.bin_path, '-X', name.shellescape)
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

      # Delete each name is a given array of names.
      # @param names    [Array<String>] An array of chains to delete.
      # @param error    [Boolean]       Determine if operations should raise/halt other possible operations with errors.
      # @param continue [Boolean]       Determine if operations should continue despite errors.
      #
      # @example Basic Usage
      #   Iptablez::Commands::DeleteChain.chain(names: ["dogs", "whales"])
      #   # => {"dogs"=>false, "whales"=>true}
      #
      # @yield  [String, Boolean] The name of the chain and result of the operation if a block if given.
      # @return [Hash]            Key value pairing of each given chain and the result of the operation.
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
