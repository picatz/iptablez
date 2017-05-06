module Iptablez
  module Commands
    module RenameChain 
      # Move on Module
      include MoveOn
      include DetermineError

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
      def self.chain(table: "filter", from:, to:, error: false, continue: !error)
        to   = to.to_s   unless to.is_a?   String 
        from = from.to_s unless from.is_a? String
        _, e, s = Open3.capture3(Iptablez.bin_path, '-t', table.shellescape, '-E', from.shellescape, to.shellescape)      
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

      def self.chains(table: "filter", pairs:, error: false, continue: !error)
        results = {}
        pairs.each do |from, to|
          results[from] = {}
          results[from][to] = chain(table: table, from: from, to: to, continue: continue) do |from, to, result|
            yield [from, to, result] if block_given?
          end
        end
        results
      end

    end
  end
end
