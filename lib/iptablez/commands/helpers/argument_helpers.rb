module Iptablez
  module Commands
    # Kent, wtf is this shit?
    # Don't worry about iiiiit bruuuhhhhhvvv.
    # @todo Make this better.
    # @author Kent 'picat' Gruber
    module ArgumentHelpers

      def self.wait(seconds: false)
        if seconds # don't wait forever? :P
          { wait: "-w #{seconds.shellescape}" }
        else
          { wait: "-w" }
        end
      end
      
      def self.comment(comment:)
        { comment: "-m comment --comment '#{comment.shellescape}'" }
      end

      def self.counters(packets:, bytes:)
        { counters: "-c #{packets.shellescape} #{bytes.shellescape}" }
      end

      def self.fragment
        { fragment: "-f" }
      end

      def self.destination(dst:, ip: true, port: !ip)
        dst = dst.shellescape
        unless port
          { destination: "-d #{dst}" }
        else
          destination_port(dst: dst)
        end
      end

      def self.destination_port(dst:)
        dst = dst.shellescape
        { destination_port: "--dport #{dst}" }
      end

      def self.source(src:, ip: true, port: !ip)
        src = src.shellescape
        unless port
          { source: "-s #{src}" }
        else
          source_port(src: src)
        end
      end

      def self.source_port(src:)
        { source_port: "-sport #{src.shellescape}" }
      end

      def self.table(name: "filter")
        { table: "-t #{name.shellescape}" }
      end

      def self.jump(target:)
        { jump: "-j #{target.shellescape}" }
      end
      
      def self.goto(target:)
        { goto: "-g #{target.shellescape}" }
      end

      def self.interface(name:, out: false)
        argument = if out
                     "-o"
                   else
                     "-i"
                   end 
        { interface: "#{argument} #{name.shellescape}" }
      end

      def self.protocol(protocol:)
        { protocol: "-p #{protocol.shellescape}" }
      end

      def self.limit(limit:)
        { limit: "-m limit --limit #{limit.shellescape}" }
      end
      
      def self.log_prefix(log_prefix:)
        { log_prefix: "--log-prefix '#{log_prefix.shellescape}'" }
      end

      def self.state(state:)
        { state: "-m state --state #{state.shellescape}"}
      end
      
      def self.states(states:)
        { states: "-m state --state #{states.map(&:shellescape).join(",")}" }
      end
      
      def self.to(to:)
        { to: "--to #{to.shellescape}" }
      end
      
      def self.icmp_type(icmp_type:)
        { icmp_type: "--icmp-type #{icmp_type.shellescape}" }
      end
      
      def self.ip_range(ip_range:)
        { ip_range: "-m iprange" }
      end
      
      def self.log_level(log_level:)
        { log_level: "--log-level #{log_level.shellescape}" }
      end

      # @example Basic Usage
      #   # note how jump: is compared to goto:
      #   args = {:goto=>"-g INPUT", :jump=>"INPUT"}
      #   # lets normalize that shit
      #   Iptablez::Commands::ArgumentHelpers.normalize_arguments(args)
      #   # => {:jump=>"-j INPUT", :goto=>"-g INPUT"}
      def self.normalize_arguments(args)
        results = {}
        results[:jump]       = normalize_jump(args[:jump])[:jump]                                 if args[:jump]
        results[:goto]       = normalize_goto(args[:goto])[:goto]                                 if args[:goto]
        results[:protocol]   = normalize_protocol(args[:protocol])[:protocol]                     if args[:protocol]
        results[:interface]  = normalize_interface(args[:interface])[:interface]                  if args[:interface]
        results[:src]        = normalize_source(args[:src])[:source]                              if args[:src]
        results[:src]        = normalize_source(args[:source])[:source]                           if args[:source]
        results[:sport]      = normalize_source(args[:sport], port: true)[:source_port]           if args[:sport]
        results[:sport]      = normalize_source(args[:source_port], port: true)[:source_port]     if args[:source_port]
        results[:dst]        = normalize_destination(args[:dst])[:destination]                    if args[:dst]
        results[:dst]        = normalize_destination(args[:destination])[:destination]            if args[:destination]
        results[:dport]      = normalize_destination(args[:dport], port: true)[:destination_port] if args[:dport]
        results[:limit]      = normalize_table(args[:limit])[:limit]                              if args[:limit] # @todo Verify this works properly.
        results[:log_prefix] = normalize_log_prefix(args[:log_prefix])[:log_prefix]               if args[:log_prefix] # @todo Verify this works properly.
        results[:ip_range]   = normalize_ip_range(args[:ip_range])[:ip_range]                     if args[:ip_range] # @todo Verify this works properly.
        results[:table]      = normalize_table(args[:table])[:table]                              if args[:table] # @todo Verify this works properly.
        results[:state]      = normalize_state(args[:state])[:state]                              if args[:state] # @todo Verify this works properly.
        results[:states]     = normalize_states(args[:states])[:states]                           if args[:states] # @todo Verify this works properly.
        results[:icmp_type]  = normalize_icmp_type(args[:icmp_type])[:icmp_type]                  if args[:icmp_type] # @todo Verify this works properly.
        results[:comment]    = normalize_comment(args[:comment])[:comment]                        if args[:comment] # @todo Verify this works properly.
        results[:dport]      = normalize_destination(args[:destination_port], port: true)[:destination_port] if args[:destination_port] # lol
        results
      end

      def self.normalize_jump(arg)
        if arg["-j"] || arg["--jump"]
          { jump: arg.shellescape }
        else
          jump(target: arg)
        end
      end
      
      def self.normalize_goto(arg)
        if arg["-g"] || arg["--goto"]
          { goto: arg.shellescape }
        else
          goto(target: arg)
        end
      end
      
      def self.ip_range(arg)
        if arg["-m iprange"]
          { ip_range: arg.shellescape }
        else
          ip_range(ip_range: arg)
        end
      end
      
      def self.normalize_icmp_type(arg)
        if arg["--icmp-type"]
          { icmp_type: arg.shellescape }
        else
          icmp_type(icmp_type: arg)
        end
      end
      
      def self.normalize_log_level(arg)
        if arg["--log-level"]
          { log_level: arg.shellescape }
        else
          log_level(log_level: arg)
        end
      end
      
      def self.normalize_log_prefix(arg)
        if arg["--log-prefix"]
          { log_prefix: arg.shellescape }
        else
          log_prefix(log_prefix: arg)
        end
      end
     
      def self.normalize_limit(arg)
        if arg["-m limit --limit"]
          { limit: arg.shellescape }
        else
          limit(limit: arg)
        end
      end
      
      def self.normalize_to(arg)
        if arg["--to"]
          { to: arg.shellescape }
        else
          to(to: arg)
        end
      end
      
      def self.normalize_state(arg)
        if arg["-m state --state"]
          { state: arg }
        else
          state(state: arg)
        end
      end
      
      def self.normalize_states(arg)
        if arg.is_a?(String) && arg["-m state --state"]
          { states: arg }
        else
          states(states: arg)
        end
      end
      
      def self.normalize_table(arg)
        if arg["-t"] || arg["--table"]
          { table: arg }
        else
          table(name: arg)
        end
      end
      
      def self.normalize_comment(arg)
        if arg["-m comment"] || arg["--match comment"]
          { comment: arg.shellescape }
        else
          comment(comment: arg)
        end
      end

      def self.normalize_protocol(arg)
        if arg["-p"] # @todo Check || arg["--protocol"]
          { protocol: arg.shellescape }
        else
          protocol(protocol: arg)
        end
      end
      
      def self.normalize_interface(arg, out: false)
        if arg["-i"] || arg["-o"] # @todo 
          { interface: arg.shellescape }
        else
          interface(name: arg, out: out)
        end
      end

      def self.normalize_table(arg)
        if arg["-t"] || arg["--table"] # @todo 
          { table: arg.shellescape }
        else
          table(name: arg)
        end
      end

      def self.normalize_destination(arg, port: false)
        if arg["-d"] || arg["--dport"] # @todo
          if port 
            { destination_port: arg.shellescape }
          else
            { destination: arg.shellescape }
          end
        else
          destination(dst: arg, port: port)
        end
      end

      def self.normalize_source(arg, port: false)
        if arg["-s"] || arg["--sport"] # @todo
          if port
            { source_port: arg.shellescape }
          else
            { source: arg.shellescape }
          end
        else
          source(src: arg, port: port)
        end
      end

    end
  end
end
