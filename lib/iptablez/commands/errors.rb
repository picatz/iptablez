module Iptablez
  module Commands
    class ChainExistenceError < ArgumentError; end

    class ChainNotEmpty < StandardError ; end 

    class InvalidRuleIndexError < StandardError; end

    class ChainAlreadyExistsError < ArgumentError; end
  end
end
