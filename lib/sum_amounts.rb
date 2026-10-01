# frozen_string_literal: true

module SumAmounts
  Obligation = Struct.new(:id, :amount_due, :priority, keyword_init: true)
  Line = Struct.new(:id, :applied, keyword_init: true)
  Settlement = Struct.new(:lines, :unapplied, keyword_init: true)

  def self.settle(_payment, _obligations)
    raise NotImplementedError, "not implemented"
  end
end
