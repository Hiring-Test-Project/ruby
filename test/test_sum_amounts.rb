# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/sum_amounts"

class TestSumAmounts < Minitest::Test
  def ob(id, amount_due, priority)
    SumAmounts::Obligation.new(id: id, amount_due: amount_due, priority: priority)
  end

  def settlement(unapplied, *pairs)
    SumAmounts::Settlement.new(
      lines: pairs.map { |id, applied| SumAmounts::Line.new(id: id, applied: applied) },
      unapplied: unapplied
    )
  end

  def test_empty
    assert_equal settlement(100), SumAmounts.settle(100, [])
  end

  def test_pays_in_full
    assert_equal(
      settlement(300, [1, 100], [2, 40], [3, 60]),
      SumAmounts.settle(500, [ob(1, 100, 1), ob(2, 40, 3), ob(3, 60, 2)])
    )
  end

  def test_higher_priority_is_paid_first
    assert_equal(
      settlement(0, [1, 0], [2, 50], [3, 10]),
      SumAmounts.settle(60, [ob(1, 80, 1), ob(2, 50, 9), ob(3, 25, 9)])
    )
  end

  def test_same_priority_pays_earlier_input_first
    assert_equal(
      settlement(0, [1, 10], [2, 0], [3, 0]),
      SumAmounts.settle(10, [ob(1, 50, 1), ob(2, 30, 1), ob(3, 20, 1)])
    )
  end

  def test_remainder_spills_to_the_next_priority
    assert_equal(
      settlement(0, [1, 20], [2, 40], [3, 60]),
      SumAmounts.settle(120, [ob(1, 100, 1), ob(2, 40, 5), ob(3, 60, 5)])
    )
  end

  def test_duplicate_id
    assert_raises(ArgumentError) do
      SumAmounts.settle(5, [ob(1, 10, 1), ob(1, 4, 2)])
    end
  end
end
