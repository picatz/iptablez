module Iptablez

  def self.bin_path
    o, e, s = Open3.capture3("which", "iptables")
    return o.strip if s.success?
    raise e
  end

  def self.version
    Commands::Version.number
  end

  def self.list(chain = false)
    if chain
      Commands::List.chain(chain)
    else
      Commands::List.all
    end
  end

  def self.chains
    Chains.all
  end

end
