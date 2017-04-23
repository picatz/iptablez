require "open3"

require "iptablez/version"
require "iptablez/helpers"
require "iptablez/command"
require "iptablez/commands/move_on"
require "iptablez/commands/argument_helpers"
require "iptablez/commands/flush_chain"
require "iptablez/commands/interface"
require "iptablez/commands/policy"
require "iptablez/commands/new_chain"
require "iptablez/commands/append_chain"
require "iptablez/commands/rename_chain"
require "iptablez/commands/delete_chain"
require "iptablez/commands/version"
require "iptablez/commands/list"
require "iptablez/chains/chains"

module Iptablez
  
  def self.squid
    # easter egg / mascot
    puts "<コ:彡"
  end

  def self.giant_squid
    puts File.read('giant_squid.txt')
  end

end
