#!/usr/bin/env ruby

require "shellwords"
require "open3"

require "iptablez/helpers/version"
require "iptablez/helpers/helpers"
require "iptablez/helpers/parser"
require "iptablez/tables/table"
require "iptablez/tables/tables"
require "iptablez/commands/helpers/move_on"
require "iptablez/commands/helpers/errors"
require "iptablez/commands/helpers/argument_helpers"
require "iptablez/commands/helpers/determine_errors"
require "iptablez/commands/flush_chain"
require "iptablez/commands/interface"
require "iptablez/commands/policy"
require "iptablez/commands/new_chain"
require "iptablez/commands/stats/bytes"
require "iptablez/commands/stats/packets"
require "iptablez/commands/stats"
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
