module Iptablez

  # Shortcut to get the bin path for `iptables`.
  # @return [String]
  def self.bin_path
    # @todo Which will fire for ever command to determine iptables path.
    # Maybe, cache this value and allow the method to be re-called when needed.
    o, e, s = Open3.capture3("which", "iptables")
    return o.strip if s.success?
    raise e
  end

  # Shortcut to get the version number for `iptables`.
  # @return [String]
  def self.version
    Commands::Version.number
  end

  # @todo Document this.
  def self.parse
    Parser
  end

  # @todo Document this.
  def self.tables
    Tables.defaults
  end

  # Shortcut to list the rules found in a chain of a given +name+ or
  # if no chain is specifcied, list all of the chains.
  # @example Basic Usage
  #   Iptablez.list
  #   # => []
  # @example Basic Usage with a Block
  #   Iptablez.list(chain: "INPUT") do |line|
  #     puts line # each line
  #   end
  def self.list(chain: false)
    if chain
      Commands::List.chain(name: chain)
    else
      Commands::List.all
    end
  end

  # Shortcut to list all of the chains.
  # @example Basic Usage
  #   Iptablez.chains
  #   # => ["INPUT", "FORWARD", "OUTPUT", "dogs", "cats"]
  # @example Basic Usage with a Block
  #   Iptablez.chains { |chain| puts chain }
  # @return [Array]
  def self.chains
    Chains.all.each { |chain| yield chain } if block_given?
    Chains.all
  end

end
