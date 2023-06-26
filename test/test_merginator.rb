# frozen_string_literal: true

require 'test_helper'

class TestMerginator < Minitest::Test
  class Setup < TestMerginator
    def test_that_it_has_a_version_number
      refute_nil ::Merginator::VERSION
    end
  end

  class PatternMerge < TestMerginator
    def test_returns_an_instance_of_pattern_merge
      result = ::Merginator.pattern_merge(4, 2, 1, total: 25)

      assert result.is_a?(::Merginator::PatternMerge)
      assert_equal [4, 2, 1], result.pattern
      assert_equal 25, result.total
    end
  end
end
