module Iptablez

  module Table 
    
    def self.list(name: "filter")
      Iptablez::Commands::List.all(table: name)
    end

    def self.policies(name: "filter")
      Iptablez::Commands::Policy.list(table: name)
    end

    def self.chains(name: "filter")
      Iptablez::Chains.defaults(table: name)
    end
     
  end
end
