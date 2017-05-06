module Iptablez
  module Commands
    # @todo Document this module. Kind'a important.
    module DetermineError 
      
      NO_CHAIN_MATCH_ERROR      = 'iptables: No chain/target/match by that name.'.freeze
      CHAIN_NOT_EMPTY           = 'iptables: Directory not empty.'.freeze
      UNKOWN_OPTION             = 'unknown option'.freeze
      PERMISSION_DENIED         = 'Permission denied (you must be root)'.freeze
      CHAIN_ALREADY_EXITS_ERROR = 'iptables: Chain already exists.'
      INVALID_RULE_NUMBER       = 'Invalid rule number'.freeze
      
      KNOWN_ERRORS = [ NO_CHAIN_MATCH_ERROR, CHAIN_NOT_EMPTY, 
                       UNKOWN_OPTION, PERMISSION_DENIED, CHAIN_ALREADY_EXITS_ERROR, 
                       INVALID_RULE_NUMBER ].freeze
      
      # @api private
      def self.determine_error(error:, chain:)
        # @todo Catch better erorrs. 
        # Default will probably not ChainNotEmpty if it's not a ChainExistenceError.
        if error == NO_CHAIN_MATCH_ERROR
          raise ChainExistenceError, "#{chain} doesn't exist!"
        elsif
          warn "Don't believe everything a program says!"
          raise ChainNotEmpty, "#{chain} is not empty! Will probably need to flush (-F) it to delete it!" 
        else
          raise error
        end
      end
    end
  end
end
