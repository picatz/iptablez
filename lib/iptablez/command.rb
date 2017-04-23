module Iptablez

  class Command
    attr_accessor :arguments

    def initialize
      clear_arguments
    end

    def clear_arguments
      @arguments = []
    end
  end

end
