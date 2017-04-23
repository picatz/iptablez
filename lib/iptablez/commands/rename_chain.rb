module Iptablez
  module Commands
    module RenameChain 
      # Move on Module
      include MoveOn


      NO_CHAIN_MATCH_ERROR = 'iptables: No chain/target/match by that name.'.freeze
      CHAIN_ALREADY_EXISTS = 'iptables: File exists.'.freeze
      KNOWN_ERRORS = [NO_CHAIN_MATCH_ERROR, CHAIN_ALREADY_EXISTS].freeze

      # @api private
      # Determine a given error. Optionally a chain can be used to provide better context.
      private_class_method def self.determine_error(error:, chain: false)
        if error == NO_CHAIN_MATCH_ERROR
          raise ChainExistenceError, "#{chain} doesn't exist!"
        elsif error == CHAIN_ALREADY_EXISTS
          raise ChainExistenceError, "#{chain} already exists!"
        else
          raise error
        end
      end
      
      # Rename a chain +from+ a given name +to+ a new name. This is the heart of this module.
      # @param from [String] Single chain name to change +from+.
      # @param to   [String] Single chain name to change +to+.
      #
      # @example Basic Usage
      #   Iptablez::Commands::RenameChain.chain(from: "dogs", to: "cats")
      #   # => true
      #   Iptablez::Commands::RenameChain.chain(from: "dogs", to: "birds")
      #   # => false
      # 
      # @yield  [String, String]
      # @return [Boolean] 
      def self.chain(from:, to:, error: false, continue: !error)
        _, e, s = Open3.capture3(Iptablez.bin_path, '-E', from, to)      
        e.strip!
        if s.success?
          yield [from, to, true] if block_given?
          return true
        elsif MoveOn.continue?(continue: continue, message: e, known_errors: KNOWN_ERRORS)
          yield [from, to, false] if block_given?
          return false
        else
          determine_error(chain: name, error: e)
        end
      end

      def self.chains(pairs:, error: false, continue: !error)
        results = {}
        pairs.each do |from, to|
          results[from] = {}
          results[from][to] = chain(from: from, to: to, continue: continue) do |from, to, result|
            yield [from, to, result] if block_given?
          end
        end
        results
      end

    end
  end
end
