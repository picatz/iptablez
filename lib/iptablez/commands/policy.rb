module Iptablez
  module Commands
    module Policy 
      # Move on Module
      include MoveOn
      include DetermineError

      def self.list(table: "filter", chain: false, chains: false)
        o, e, s = Open3.capture3(Iptablez.bin_path, '-t', table.shellescape, '-S')
        e.strip!
        if s.success?
          if chain
            list_rules_to_policy(chain, o)
          elsif chains
            results = {}
            Iptablez::Parser.list_rules_to_policy(o) do |c, rule|
              next unless chains.include?(c)
              yield [chain, result]
              result[chain] = result
            end
            results
          else
            Iptablez::Parser.list_rules_to_policies(o) do |result|
              yield result if block_given?
            end
          end
        elsif MoveOn.continue?(continue: continue, message: e, known_errors: KNOWN_ERRORS)
          yield [name, target, false] if block_given?
          return false
        else
          determine_error(chain: name, error: e)
        end
      end

      def self.all(table: "filter", target:, error: false, continue: !error)
        if target
          chains(table: table, names: Iptablez::Chains.defaults, target: target, continue: continue) do |result|
            yield result if block_given?
          end
        else
          Iptables::Chains.policies do |result|
            yield result
          end
        end  
      end

      def self.defaults(table: "filter", target:, error: false, continue: !error)
        chains(table: table, names: Iptablez::Chains.defaults, target: target, continue: continue) do |result|
          yield result if block_given?
        end
      end

      def self.chain(table: "filter", name:, target:, error: false, continue: !error)
        _, e, s = Open3.capture3(Iptablez.bin_path, '-t', table.shellescape, '-P', name, target)      
        e.strip!
        if s.success?
          yield [name, target, true] if block_given?
          return true
        elsif MoveOn.continue?(continue: continue, message: e, known_errors: KNOWN_ERRORS)
          yield [name, target, false] if block_given?
          return false
        else
          determine_error(chain: name, error: e)
        end
      end

      def self.chains(table: "filter", names:, target:, error: false, continue: !error)
        results = {}
        names.each do |name|
          results[name] = {}
          results[name][target] = chain(table: table, name: name, target: target, continue: continue) do |result|
            yield result if block_given?
          end
        end
        results
      end

    end
  end
end
