module Iptablez
  module Commands
    # The namespace to describe the `iptables` `-X` argument to delete a chain.
    # @author Kent 'picat' Gruber
    module AppendChain
      # Move on Module
      include MoveOn
      include ArgumentHelpers

      # Simple Error class to document errors that occur when a chain doesn't exist.
      # @author Kent 'picat' Gruber
      class ChainExistenceError < ArgumentError; end
      
      NO_CHAIN_MATCH_ERROR = 'iptables: No chain/target/match by that name.'.freeze
      KNOWN_ERRORS = [NO_CHAIN_MATCH_ERROR].freeze

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
      def self.chain(name:, error: false, continue: !error, **args)
        first_arguments = [Iptablez.bin_path, '-A', name]
        args = ArgumentHelpers.normalize_arguments(args).values.map(&:split).flatten # fucking crazy shit here
        cmd = first_arguments + args
        _, e, s = Open3.capture3(cmd.join(" "))
        #_, e, s = Open3.capture3(Iptablez.bin_path, '-A', name, args.values.map(&:split).flatten)
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

    end
  end
end
