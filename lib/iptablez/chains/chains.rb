module Iptablez

  module Chains
    
    DEFAULT = ["INPUT", "FORWARD", "OUTPUT"]

    # List all of the current chains found in +iptables+.
    #
    # @example Basic Usage
    #   Iptablez::Chains.all
    #   # => ["INPUT", "FORWARD", "OUTPUT"]
    #
    # @example Block Usage
    #   Iptablez::Chains.all do |chain|
    #     puts chain
    #   end
    #
    # @yield Each chain if a block is given.
    # @return [Array<String>] An array of chain names.
    def self.all(table: "filter")
      chains = Commands::List.full(table: table).find_all do |line| 
        line if line.split[0] == "Chain" 
      end.map(&:split).collect { |array| array[1] }
      chains.each { |c| yield c } if block_given?
      return chains 
    end
    
    # List the default policies for default chains.
    #
    # @example Basic Usage
    #   Iptablez::Chains.policies
    #   # => {"INPUT"=>"ACCEPT", "FORWARD"=>"ACCEPT", "OUTPUT"=>"ACCEPT"}
    #
    # @example Block Usage
    #   Iptablez::Chains.policies do |name, policy|
    #     puts "#{name}: #{policy}"
    #   end
    #
    # @yield Each chain name and policy if a block is given.
    # @return [Hash] Key value pairing of each chain and its default policy.
    def self.policies(table: "filter", names: Iptablez::Chains.defaults, error: false, continue: !error)
      Commands::List.defaults(table: table, names: names, continue: continue) do |result|
        yield result if block_given?
      end
    end

    # Check if there are any user defined chains, optionally
    # giving a single name to check or an array of names.
    #
    # @example Basic Usage
    #   Iptablez::Chains.user_defined?
    #   # => false
    # @example Basic Block Usage
    #   Iptablez::Chains.user_defined? do |result|
    #     if result
    #       puts "Found user defined chains."
    #     else
    #       puts "Did not find user defined chains."
    #     end
    #   end
    # @example Check Single Name
    #   Iptablez::Chains.user_defined?(name: "dogs")
    #   # => false
    # @example Check Single Name with a Block
    #   Iptablez::Chains.user_defined?(name: "dogs") do |result|
    #     result ? "User defined!" : "No user defined!"     
    #   end
    # @example Check Multiple Names
    #   Iptablez::Chains.user_defined?(names: ["dogs", "frogs"])
    #   # => {"dogs"=>false, "frogs"=>false}
    # @example Check Multiple Names with a Block
    #   Iptablez::Chains.user_defined?(names: ["dogs", "frogs"]) do |name, result|
    #     phrase = if result
    #                "is"
    #              else
    #                "is not"
    #              end
    #     puts "#{name} #{phrase} user defined."
    #   end
    # @param name [String] Single name.
    # @param names [Array<String>] Multiple names.
    # 
    # @yield results if a block is given.
    # @return [Hash] key value pairing of each chain and the result of the check.
    def self.user_defined?(table: "filter", name: false, names: [])
      if name && names.empty?
        r = user_defined(table: table).include?(name)
        return r unless block_given?
        yield r
      elsif names[0] && ! name
        r = {}
        names.each do |n|
          r.clear if block_given?
          r[n] = user_defined(table: table).include?(n)
          yield r.flatten if block_given?
        end
        return r unless block_given? 
      elsif names[0] && name
        raise "Cannot use both a single name and multiple names together."
      else
        all.count > 3 ? true : false
      end
    end

    # List all of the user_defined chains.
    #
    # @yield Each name of the user defined chains if a block if given.
    # @return [Array<String>] Easy user defined chain as an array.
    def self.user_defined(table: "filter")
      user_defined_chains = all.find_all { |c| c unless DEFAULT.include?(c) }
      return user_defined_chains unless block_given?
      user_defined_chains.each { |c| yield c }
    end

    # Check if a chain exists by a given name.
    # @todo Fix documentation.
    # @param name [String] Single name.
    # @param names [Array<String>] Multiple names.
    # @return [Boolean] Easy user defined chain as an array.
    def self.exists?(table: "filter", name: false, names: [])
      if name
        all do |chain| 
          if chain == name 
            yield [name, true] if block_given?
            return true
          end
        end
      elsif !names.empty?
        results = {}
        names.each do |name|
          results[name] = false
          all { |chain| results[name] = true if chain == name }
          yield [name, results[name]] if block_given?
        end
        results
      end
    end

    def self.defaults(table: "filter")
      case table
      when "filter"
        [ "INPUT", "FORWARD", "OUTPUT" ].each { |chain| yield chain } if block_given? 
        [ "INPUT", "FORWARD", "OUTPUT" ] 
      when "nat"
        [ "PREROUTING", "INPUT", "OUTPUT", "POSTROUTING" ].each { |chain| yield chain } if block_given? 
        [ "PREROUTING", "INPUT", "OUTPUT", "POSTROUTING" ] 
      when "mangle"
        [ "PREROUTING", "INPUT", "FORWARD", "OUTPUT", "POSTROUTING" ].each { |chain| yield chain } if block_given?
        [ "PREROUTING", "INPUT", "FORWARD", "OUTPUT", "POSTROUTING" ]
      when "raw"
        [ "PREROUTING", "OUTPUT" ].each { |chain| yield chain } if block_given?
        [ "PREROUTING", "OUTPUT" ]
      when "security"
        [ "INPUT", "FORWARD", "OUTPUT" ].each { |chain| yield chain } if block_given?
        [ "INPUT", "FORWARD", "OUTPUT" ]
      else
        false
      end
    end

    def self.policy?(table: "filter", name: false, policy: false, names: [])
      if name && names.empty?
        r = if policies[name] == policy
              true
            else
              false
            end
        return r unless block_given?
        yield r
      elsif names[0] && ! name && policy
        r = {} 
        names.each do |n| 
          begin
            r[n] = if policies[n] == policy
                     true 
                   else
                     false
                   end
            yield r[n] if block_given?
          rescue => e
            raise e
          end
        end
        return r unless block_given? 
      elsif name && names[0]
        raise "Cannot use both a single name and multiple names together."
      end
    end 
   
    def self.stats
      Commands::Stats
    end
    
    def self.packets
      Commands::Stats::Packets
    end

    def self.bytes
      Commands::Stats::Bytes
    end

    def self.list
      Commands::List
    end
  
    def self.new_chain
      Commands::NewChain
    end

    def self.delete_chain
      Commands::DeleteChain
    end

    def self.flush_chain
      Commands::FlushChain
    end

    def self.rename_chain
      Commands::RenameChain
    end

    def self.append_chain
      Commands::AppendChain
    end

    def self.create(name: false, names: [], error: false, continue: !error)
      if name
        Commands::NewChain.chain(name: name, continue: continue) do |result|
          yield result if block_given?
        end
      elsif !names.empty?
        Commands::NewChain.chains(names: names, continue: continue) do |result|
          yield result if block_given?
        end  
      end
    end

    def self.delete(name: false, names: [], error: false, continue: !error)
      if name 
        Commands::DeleteChain.chain(name: name, continue: continue) do |result|
          yield result if block_given?
        end
      elsif !names.empty?
        Commands::DeleteChain.chains(names: names, continue: continue) do |result|
          yield result if block_given?
        end
      end
    end

    def self.flush(name: false, names: [], error: false, continue: !error)
      if name
        Commands::FlushChain.chain(name: name, continue: continue) do |result|
          yield result if block_given?
        end
      elsif !names.empty?
        Commands::FlushChain.chains(names: names, continue: continue) do |result|
          yield result if block_given?
        end
      end
    end
    
    def self.rename(from: false, to: false, pairs: {}, error: false, continue: !error)
      if from && to
        Commands::RenameChain.chain(from: from, to: to, continue: continue) do |result|
          yield result if block_given?
        end
      elsif (!from && to) or (from && !to)
        return false if continue
        raise ArgumentError, "Cannot use from: without to:"
      elsif !pairs.empty?
        Commands::RenameChain.chains(pairs: pairs, continue: continue) do |result|
          yield result if block_given?
        end
      end
    end
    
    def self.append(name: false, names: [], error: false, continue: !error, **args)
      if name
        Commands::AppendChain.chain(name: name, continue: continue, **args)
      elsif !names.empty?
        Commands::AppendChain.chains(names: names, continue: continue, **args)
      end
    end
    
    def self.policy(target:, name: false, names: [], error: false, continue: !error)
      if name
        Commands::Policy.chain(target: target, name: name, continue: continue) do |result|
          yield result if block_given?
        end
      elsif !names.empty?
        Commands::Policy.chains(target: target, names: names, continue: continue) do |result|
          yield result if block_given?
        end  
      end
    end

  end

end
