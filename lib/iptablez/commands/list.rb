module Iptablez
  module Commands
    module List 
      # Move on Module
      include MoveOn
      
      # Simple Error class to document errors that occur when a chain doesn't exist.
      # @author Kent 'picat' Gruber
      class ChainExistenceError < ArgumentError; end
      
      # Simple Error class to document errors that occur when a user/process lacks permissions.
      # @author Kent 'picat' Gruber
      class InvalidRuleIndexError < StandardError; end

      UNKOWN_OPTION        = 'unknown option'.freeze
      NO_CHAIN_MATCH_ERROR = 'iptables: No chain/target/match by that name.'.freeze
      PERMISSION_DENIED    = 'Permission denied (you must be root)'.freeze
      INVALID_RULE_NUMBER  = 'Invalid rule number'.freeze

      KNOWN_ERRORS = [NO_CHAIN_MATCH_ERROR, PERMISSION_DENIED, INVALID_RULE_NUMBER, UNKOWN_OPTION].freeze

      # @api private
      # Determine a given error. Optionally a chain can be used to provide better context.
      private_class_method def self.determine_error(error:, chain: false, number: false)
        if error == NO_CHAIN_MATCH_ERROR
          raise ChainExistenceError, "#{chain} doesn't exist!"
        elsif error == INVALID_RULE_NUMBER
          raise InvalidRuleIndexError, "#{chain} invalid number #{number}!"
        else
          raise error
        end
      end

      # List all of the `iptables` rules. Note: this will not include policies.
      # @todo Document params.
      # @example Basic Usage
      #   Iptablez::Commands::List.all
      #   # => []
      #   Iptablez::Commands::List.all.empty? # if no rules
      #   # => true
      # @example Basic Usage with a Block
      #   Iptablez::Commands::List.all do |rule|
      #     puts rule
      #   end
      # @yield Each result if a block is given.
      # @return [Hash] key value pairing of each chain and the result of the check.
      def self.all(error: false, continue: !error)
        o, e, s = Open3.capture3(Iptablez.bin_path, '-L')      
        if e["you must be root"]
          e = PERMISSION_DENIED
        else
          e.strip!
        end
        results = []
        if s.success?
          o.split("\n").map(&:strip).each do |line|
            next if line.split[0] == "Chain" || line.split[0] == "target" || line.empty?
            yield line if block_given?
            results << line
          end
          results
        elsif MoveOn.continue?(continue: continue, message: e, known_errors: KNOWN_ERRORS)
          return results
        else
          determine_error(chain: name, error: e)
        end
      end

      # List the `iptables` rules for a chain of a given `name`.
      # @todo Document params.
      # @example Basic Usage
      #   Iptablez::Commands::List.defaults
      #   # => {"INPUT"=>"ACCEPT", "FORWARD"=>"ACCEPT", "OUTPUT"=>"ACCEPT"}
      # @example Basic Usage with a Block
      #   Iptablez::Commands::List.defaults do |name, target|
      #     puts "#{name}: #{target}"
      #   end
      def self.defaults(names: Iptablez::Chains.defaults, error: false, continue: !error)
        results = {}
        names.each do |name|
          result = chain(name: name, policy: true, continue: true)
          result = result.map(&:split).map(&:last)[0] if result
          yield [name, result] if block_given?
          results[name] = result
        end
        results
      end
     
      # List the full `iptables` output (no filtering from STDOUT) for a `chain` of a given name, or
      # all chains if no chain `name` is given.
      # @todo Document params.
      # @example Basic Usage
      #   Iptablez::Commands::List.full
      #   Iptablez::Commands::List.full(chain: "INPUT")
      # @example Basic Usage with a Block
      #   Iptablez::Commands::List.full { |l| puts l }
      #   Iptablez::Commands::List.full(chain: "FORWARD") do |line|
      #     puts line
      #   end
      # @yield Each result if a block is given.
      # @return [Array] Each line as the result.
      def self.full(chain: false, error: false, continue: !error)
        if chain
          o, e, s = Open3.capture3(Iptablez.bin_path, '-L', chain)      
        else
          o, e, s = Open3.capture3(Iptablez.bin_path, '-L')      
        end
        e.strip!
        if s.success?
          return o.split("\n").map(&:strip).each do |line|
            yield line if block_given?
          end
        elsif MoveOn.continue?(continue: continue, message: e, known_errors: KNOWN_ERRORS)
          return false
        else
          determine_error(chain: name, error: e)
        end
      end

      # List a rule for a `chain` of a given name and `number`.
      # @example Basic Usage
      #   Iptablez::Commands::List.number(chain: "INPUT", number: 1)
      #   # => false
      #   Iptablez::Commands::List.number(chain: "FORWARD", number: 1)
      #   # => String containing rule number 1 from the FOWARD chain.
      # @example Basic Usage with a Block
      #   Iptablez::Commands::List.number(chain: "INPUT", number: 1) do |chain, num, result|
      #     puts "Rule #{num} in #{chain} is #{result}" if result
      #   end
      def self.number(chain:, number:, error: false, continue: !error)
        if number.is_a? Integer
          if number <= 0 && error
            raise ArgumentError, "Invalid rule number #{number}!"
          else
            number = number.to_s
          end
        end
        o, e, s = Open3.capture3(Iptablez.bin_path, '-L', chain, number.to_s)      
        e.strip!
        o.strip!
        o = false if o.empty?
        e = INVALID_RULE_NUMBER if e["Invalid rule number"]
        e = UNKOWN_OPTION if e[": unknown option "]
        if s.success?
          yield [chain, number, o] if block_given?
          return o
        elsif MoveOn.continue?(continue: continue, message: e, known_errors: KNOWN_ERRORS)
          return false
        else
          determine_error(chain: name, error: e, number: number)
        end
      end

      # Determine if there is a rule for a given `chain` name with a given `number`.
      # @example Basic Usage
      #   Iptablez::Commands::List.number?(chain: "INPUT", number: 1)
      #   # => false
      #   Iptablez::Commands::List.number?(chain: "FORWARD", number: 1)
      #   # => true
      def self.number?(chain:, number:, error: false, continue: !error)
        if number(chain: chain, number: number, continue: continue)
          true
        else
          false
        end
      end
      
      # Determine if a given `number` could even be a possible number. Note: this will not
      # check `iptables` for validation.
      # @example Basic Usage
      #   Iptablez::Commands::List.possible_valid_number?(number: 2)
      #   # => true
      #   Iptablez::Commands::List.possible_valid_number?(number: 0)
      #   # => false
      def self.possible_valid_number?(number:)
        number = number.to_i if number.is_a? String
        if number >= 1
          true
        else
          false
        end
      end

      # List the `iptables` rules for a chain of a given `name`. Optionally, you
      # may specify to include `policy` information which can be helpful.
      # @example Basic Usage
      #   Iptablez::Commands::List.chain(name: "INPUT")
      #   # => []
      #   Iptablez::Commands::List.chain(name: "INPUT", policy: true)
      #   # => ["-P INPUT ACCEPT"]
      # @example Basic Usage with a Block
      #   Iptablez::Commands::List.chain(name: "INPUT", policy: true) do |rule|
      #     puts rule
      #   end
      def self.chain(name:, policy: false, error: false, continue: !error)
        if policy
          o, e, s = Open3.capture3(Iptablez.bin_path, '-S', name)      
        else
          o, e, s = Open3.capture3(Iptablez.bin_path, '-L', name)      
        end
        e.strip!
        if s.success?
          results = o.split("\n").map(&:strip).delete_if do |line|
            line if line.split[0] == "Chain" || line.split[0] == "target"
          end
          results.each do |line|
            yield line if block_given?
          end
          results
        elsif MoveOn.continue?(continue: continue, message: e, known_errors: KNOWN_ERRORS)
          return false
        else
          determine_error(chain: name, error: e)
        end 
      end
    end
  end
end
