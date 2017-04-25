module Iptablez
  module Commands
    # Kent, wtf is this shit?
    # Don't worry about iiiiit bruuuhhhhhvvv.
    # @author Kent 'picat' Gruber
    module ArgumentHelpers

      def self.wait(seconds: false)
        if seconds # don't wait forever? :P
          { wait: "-w #{seconds}" }
        else
          { wait: "-w" }
        end
      end

      def self.counters(packets:, bytes:)
        { counters: "-c #{packets} #{bytes}" }
      end

      def self.fragment
        { fragment: "-f" }
      end

      def self.destination(dst:, ip: true, port: !ip)
        unless port
          { destination: "-d #{dst}" }
        else
          destination_port(dst: dst)
        end
      end

      def self.destination_port(dst:)
        { destination_port: "--dport #{dst}" }
      end

      def self.source(src:, ip: true, port: !ip)
        unless port
          { source: "-s #{src}" }
        else
          source_port(src: src)
        end
      end

      def self.source_port(src:)
        { source_port: "-sport #{src}" }
      end

      # @todo
      #def self.ip_range(from:, to:)
      #  { ip_range: "-m iprange #{fromt}-#{to}" }
      #end

      def self.table(name: "filter")
        { table: "-t #{name}" }
      end

      def self.jump(target:)
        { jump: "-j #{target}" }
      end
      
      def self.goto(target:)
        { goto: "-g #{target}" }
      end

      def self.interface(name:, out: false)
        argument = if out
                     "-o"
                   else
                     "-i"
                   end 
        { interface: "#{argument} #{name}" }
      end

      def self.protocol(protocol:)
        { protocol: "-p #{protocol}" }
      end

      # @example Basic Usage
      #   # note how jump: is compared to goto:
      #   args = {:goto=>"-g INPUT", :jump=>"INPUT"}
      #   # lets normalize that shit
      #   Iptablez::Commands::ArgumentHelpers.normalize_arguments(args)
      #   # => {:jump=>"-j INPUT", :goto=>"-g INPUT"}
      def self.normalize_arguments(args)
        results = {}
        results[:jump]     = normalize_jump(args[:jump])[:jump]                                 if args[:jump]
        results[:goto]     = normalize_goto(args[:goto])[:goto]                                 if args[:goto]
        results[:protocol] = normalize_protocol(args[:protocol])[:protocol]                     if args[:protocol]
        results[:interface]= normalize_interface(args[:interface])[:interface]                  if args[:interface]
        results[:src]      = normalize_source(args[:src])[:source]                              if args[:src]
        results[:sport]    = normalize_source(args[:sport], port: true)[:source_port]           if args[:sport]
        results[:dst]      = normalize_destination(args[:dst])[:destination]                    if args[:dst]
        results[:dport]    = normalize_destination(args[:dport], port: true)[:destination_port] if args[:dport]
        results
      end

      def self.normalize_jump(arg)
        if arg["-j"] || arg["--jump"]
          { jump: arg }
        else
          jump(target: arg)
        end
      end
      
      def self.normalize_goto(arg)
        if arg["-g"] || arg["--goto"]
          { goto: arg }
        else
          goto(target: arg)
        end
      end

      def self.normalize_protocol(arg)
        if arg["-p"] # @todo Check || arg["--protocol"]
          { protocol: arg }
        else
          goto(target: arg)
        end
      end
      
      def self.normalize_interface(arg, out: false)
        if arg["-i"] || arg["-o"] # @todo 
          { interface: arg }
        else
          interface(name: arg, out: out)
        end
      end

      def self.normalize_table(arg)
        if arg["-t"] || arg["--table"] # @todo 
          { table: arg }
        else
          table(name: arg)
        end
      end

      def self.normalize_destination(arg, port: false)
        if arg["-d"] || arg["--dport"] # @todo
          if port 
            { destination_port: arg }
          else
            { destination: arg }
          end
        else
          destination(dst: arg, port: port)
        end
      end

      def self.normalize_source(arg, port: false)
        if arg["-s"] || arg["--sport"] # @todo
          if port
            { source_port: arg }
          else
            { source: arg }
          end
        else
          source(src: arg, port: port)
        end
      end

    end
  end
end
