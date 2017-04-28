module Iptablez
  module Commands
    module Stats 
      module Packets       
        include MoveOn

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

        def self.chain(name:, error: false, continue: !error, **args)
          o, e, s = Open3.capture3(Iptablez.bin_path, '-L', name, '-v', '-n')      
          e.strip! # remove new line
          if s.success?
            result = if Iptablez::Chains.defaults.include?(name)
                       default_chain(o)
                     else
                       user_defined_chain(o)              
                     end
            yield [name, result] if block_given?
            return result
          elsif MoveOn.continue?(continue: continue, message: e, known_errors: KNOWN_ERRORS)
            yield [name, false] if block_given?
            return false
          else
            determine_error(chain: name, error: e)
          end
        end

        def self.user_defined_chain(o)
          result = 0
          o = o.split("\n")
          2.times { o.delete_at(0) }
          o.each { |line| result += line.split[0].to_i }
          yield result if block_given?
          result 
        end

        def self.default_chain(o)
          o = o.split("\n")
          result = o[0].match(/\d+/).to_s.to_i
          yield result if block_given?
          result
        end
        
        def self.chains(names:, error: false, continue: !error, **args)
          results = {}
          names.each do |name|
            results[name] = chain(name: name, continue: continue) do |name, result|
              yield [name, result] if block_given?
            end
          end
          results
        end

        def self.all(names: Iptablez::Chains.all, error: false, continue: !error)
          chains(names: names, continue: continue) do |name, result|
            yield [name, result] if block_given?
          end
        end

      end
    end
  end
end
