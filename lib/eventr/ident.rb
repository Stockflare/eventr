module Eventr
  module Ident

    extend ActiveSupport::Concern

    extend Ident

    included do

      self.cattr_accessor :eventr_ident_id
      self.eventr_ident_id = Proc.new { id }

      def self.ident(sym = nil, &call)
        self.eventr_ident_id = if sym
          Proc.new { send(sym.to_sym) }
        else
          call
        end
      end

    end

    # private

    def ident_id
      instance_eval &self.class.eventr_ident_id
    end

  end
end
