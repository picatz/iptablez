module Iptablez
  module Commands
    # The namespace to describe the `iptables` `-X` argument to delete a chain.
    # @author Kent 'picat' Gruber
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
