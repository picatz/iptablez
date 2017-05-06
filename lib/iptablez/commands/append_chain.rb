module Iptablez
  module Commands
    # The namespace to describe the `iptables` `-X` argument to delete a chain.
    # @author Kent 'picat' Gruber
    module AppendChain
      # Move on Module
      include MoveOn
      include ArgumentHelpers
      include DetermineError 

      # Delete a chain of a given +name+. This is the heart of this module.
      # @param name     [String]  Single chain +name+.
      # @param error    [Boolean] Determine if operations should raise/halt other possible operations with errors.
      # @param continue [Boolean] Determine if operations should continue despite errors.
      #
      # @example Basic Usage
      #   Iptablez::Commands::AppendChain.chain(name: "dogs")
      #   # => true
      #   Iptablez::Commands::List.chain(name: "kittens")
      #   # => ["all  --  anywhere             anywhere"]
      #
      # @yield  [String, Boolean] The +name+ of the chain and +result+ of the operation if a block if given.
      # @return [Boolean]         The result of the operation.
      #
      # @raise An error will be raised if the +error+ or +continue+ keywords are +true+ and the operation fails.
      def self.chain(table: "filter", name:, error: false, continue: !error, **args)
        name = name.to_s unless name.is_a? String
        name = name.shellescape
        first_arguments = [Iptablez.bin_path, '-t', table.shellescape, '-A', name.shellescape]
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

      def self.chains(table: "filter", names:, error: false, continue: !error, **args)
        results = {} 
        names.each do |name|
          results[name] = chain(table: table, name: name, continue: continue, **args) do |name, result|
            yield [name, result] if block_given?
          end
        end
        results 
      end

    end
  end
end
