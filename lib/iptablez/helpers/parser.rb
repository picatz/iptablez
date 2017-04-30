module Iptablez

  # @todo This whole thing needs some documentation.
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

    # iptables -S
    def self.list_rules_to_array(output = `iptables -S`)
      results = []
      output.split("\n").each do |line|  
        next line if line.empty?
        yield line if block_given?
        results << line
      end
      results
    end

    # iptables -S
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

    # iptables -S
    def self.list_rules_to_policy(chain, output = `iptables -S`)
      output.split("\n").each do |line|
        next unless line.match(/-P\s#{chain}/)
        chain, rule = line.split[1,2]
        yield [chain, rule] if block_given?
        return { chain => rule }
      end
      return false
    end

    def self.list_to_hashes(output = `iptables -L`)
      results = []
      output.split("\n").each do |line|
        next if line.empty?
        result = list_line_to_hash(line)
        next if result[:info]
        yield result if block_given?
        results << result
      end
      results
    end
    
    def self.list_line_to_hash(line)
      return {info: true} if line.match(/^\btarget\s/)
      return {info: true} if line.match(/\spkts\sbytes/)
      return {info: true} if line.match(/^num\s+target+\s+/)
      return chain_line(line) if line.match(/Chain\s/)
      return rule_line(line: line, types: [:default])  if line.match(/^\w+\s+\w+\s+--/)      # @todo Fix this, weak check. 
      return rule_line(line: line, types: [:numbers])  if line.match(/^\d\s+\w+\s+\w+\s+--/) # @todo Fix this, weak check.
      return rule_line(line: line, types: [:verbose])  if line.match(/^\s+\d+\s+\d+\s+\D/) 
      return rule_line(line: line, types: [:verbose, :numbers])  if line.match(/^\d+\s+\d+\s+\d+\s+\D/) 
    end

    def self.chain_line(line)
      line = line.split
      result = {}
      result[:chain]   = line[1]
      result[:policy]  = line[3].gsub(")","")
      result[:packets] = line[4].gsub(")","").to_i if line[4]
      result[:bytes]   = line[6].gsub("K","").to_i if line[6]
      result 
    end

    def self.rule_line(line:, types:)
      result = {}
      line = line.split
      case types
      when [:default] # -L
        result[:target]      = line[0] # Watching a talk from GopherCon 2016: The Design of the Go Assembler
        result[:protocol]    = line[1] # by Rob Pike -- I've been on a GoLang binge recently.
        result[:opt]         = line[2]
        result[:source]      = line[3] # Random thoughts will coding.
        result[:destination] = line[4]
        result[:comment]     = line[5, line.count].join(" ").gsub(/^\/\*\s/,"").gsub(/\s\*\/$/,"") if line[5]
        return result
      when [:numbers] # --line-number
        result[:number]      = line[0].to_i
        result[:target]      = line[1]
        result[:protocol]    = line[2]
        result[:opt]         = line[3]
        result[:source]      = line[4]
        result[:destination] = line[5]
        result[:comment]     = line[6, line.count].join(" ").gsub(/^\/\*\s/,"").gsub(/\s\*\/$/,"") if line[6]
        return result
      when [:verbose] # -v
        result[:packets]     = line[0].to_i
        result[:bytes]       = line[1].to_i
        result[:target]      = line[2]
        result[:protocol]    = line[3]
        result[:opt]         = line[4]
        result[:in]          = line[5]
        result[:out]         = line[6]
        result[:source]      = line[7]
        result[:destination] = line[8]
        result[:comment]     = line[9, line.count].join(" ").gsub(/^\/\*\s/,"").gsub(/\s\*\/$/,"") if line[9]
        return result
      when [:verbose, :numbers] # -v --line-number
        result[:number]      = line[0].to_i
        result[:packets]     = line[1].to_i
        result[:bytes]       = line[2].to_i
        result[:target]      = line[3]
        result[:protocol]    = line[4]
        result[:opt]         = line[5]
        result[:in]          = line[6]
        result[:out]         = line[7]
        result[:source]      = line[8]
        result[:destination] = line[9]
        result[:comment]     = line[10, line.count].join(" ").gsub(/^\/\*\s/,"").gsub(/\s\*\/$/,"") if line[10]
        return result
      end
      false # no dice?
    end

  end

end
