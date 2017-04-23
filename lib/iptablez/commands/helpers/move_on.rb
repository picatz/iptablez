module Iptablez
  module Commands
    # @todo Document this module. Kind'a important.
    module MoveOn
      # @api private
      # Determine if the method should should move on with its life when things go wrong.
      def self.continue?(continue:, message:, known_errors:, force: false)
        return true if force
        return true if continue && known_errors.include?(message)
        false
      end
    end
  end
end
