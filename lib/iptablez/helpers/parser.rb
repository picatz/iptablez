module Iptablez

  module Parser
    
    # @todo Document better
    # iptables -L
    # iptables -L -v
    def self.list_to_array(output)
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
    def self.list_to_chains(output)
      results = []
      output.split("\n").each do |line|
        next unless line.match(/\bChain\s\w+/)
        chain = line.split[1]
        yield chain if block_given?
        results << chain
      end
      results
    end    

  end

end
