module Iptablez

  module Parser
    
    # @todo Document better
    # iptables -L
    # iptables -L -v
    def self.list_to_array(output = `iptables -L`)
      results = []
      output.split("\n").each do |line|
        next if line.match(/\bChain\s\w+\s\(\w+\s+\w+(\s+\w+\spackets,\s\w+\sbytes)?\)/) 
        next if line.match(/(\spkts\sbytes\s)?target\s+prot\sopt\s(in\s+out\s+)?source\s+destination/) 
        next if line.empty?
        yield line if block_given?
        results << line
      end
      results
    end    

    # @todo Document better
    # iptables -L
    # iptables -L -v
    def self.list_to_chains(output = `iptables -L`)
      results = []
      output.split("\n").each do |line|
        next unless line.match(/\bChain\s\w+/)
        chain = line.split[1]
        yield chain if block_given?
        results << chain
      end
      results
    end    

    def self.list_rules_to_array(output = `iptables -S`)
      results = []
      output.split("\n").each do |line|  
        next line if line.empty?
        yield line if block_given?
        results << line
      end
      results
    end

    def self.list_rules_to_policies(output = `iptables -S`)
      results = {}
      output.split("\n").each do |line|
        next unless line.match(/-P\s/)
        chain, rule = line.split[1,2]
        yield [chain, rule] if block_given?
        results[chain] = rule
      end
      results
    end

    def self.list_rules_to_policy(policy, output = `iptables -S`)
      output.split("\n").each do |line|
        next unless line.match(/-P\s#{policy}/)
        chain, rule = line.split[1,2]
        yield [chain, rule] if block_given?
        return { chain => rule }
      end
      return false
    end

  end

end
