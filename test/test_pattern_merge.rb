# frozen_string_literal: true

require 'test_helper'

class TestPatternMerge < Minitest::Test
  class KindOfArray < Array; end

  class Initialize < TestPatternMerge
    def test_more_than_one_pattern_required
      error = assert_raises ArgumentError do
        Merginator::PatternMerge.new(1)
      end

      expected_message = 'there must be more than one collection in the pattern'
      assert_equal expected_message, error.message
    end

    def test_pattern_must_be_all_integers
      error = assert_raises ArgumentError do
        Merginator::PatternMerge.new('1', '2')
      end

      expected_message = 'pattern must be all integers'
      assert_equal expected_message, error.message
    end

    def test_total_not_required
      # assert_nothing_raised
      Merginator::PatternMerge.new(1, 2)

      # assert_nothing_raised
      Merginator::PatternMerge.new(1, 2, total: 5)
    end

    def test_total_must_be_ge_one
      error = assert_raises ArgumentError do
        Merginator::PatternMerge.new(1, 2, total: 0)
      end

      expected_message = 'total must be at least 1'
      assert_equal expected_message, error.message
    end

    def test_generates_counts_if_total_present
      no_counts = Merginator::PatternMerge.new(1, 2)
      refute no_counts.counts

      yes_counts = Merginator::PatternMerge.new(1, 2, total: 10)
      assert yes_counts.counts
    end

    def test_wrapper_is_optional
      # assert_nothing_raised
      Merginator::PatternMerge.new(1, 2)

      # assert_nothing_raised
      Merginator::PatternMerge.new(1, 2, wrapper: [])
    end

    def test_wrapper_must_be_array
      # assert_nothing_raised
      Merginator::PatternMerge.new(1, 2, wrapper: KindOfArray.new)

      # assert_nothing_raised
      Merginator::PatternMerge.new(1, 2, wrapper: [])

      error = assert_raises ArgumentError do
        Merginator::PatternMerge.new(1, 2, wrapper: '')
      end

      expected_message = 'wrapper must be like an array'
      assert_equal expected_message, error.message
    end
  end

  class Counts < TestPatternMerge
    def test_generates_pattern_counts_properly
      tests = [
        [[11, 4, 6], Merginator::PatternMerge.new(5, 2, 3, total: 21)],
        [[6, 20, 4], Merginator::PatternMerge.new(3, 10, 3, total: 30)],
        [[5, 10, 15], Merginator::PatternMerge.new(1, 2, 3, total: 30)],
        [[200, 70, 30], Merginator::PatternMerge.new(50, 20, 10, total: 300)]
      ]

      tests.each do |expected, mergifier|
        assert_equal expected, mergifier.counts
      end
    end
  end

  class Merge < TestPatternMerge
    def setup
      super

      @mergifier = Merginator::PatternMerge.new(5, 2, 3, total: 21)
    end

    def test_number_of_collections_must_match_pattern_length
      collections = [[1], [2]]
      refute_equal collections.count, @mergifier.pattern.count

      error = assert_raises ArgumentError do
        @mergifier.merge(*collections)
      end

      expected_message = 'number of collections must match pattern; expected 3 collections, actual: 2'
      assert_equal expected_message, error.message
    end

    def test_number_of_elements_must_be_gte_total
      collections = [[1], [2], [3]]
      refute_operator collections.flatten.count, :>=, @mergifier.total

      error = assert_raises ArgumentError do
        @mergifier.merge(*collections)
      end

      expected_message = 'total number of elements in collections must be >= '
      expected_message += 'provided total; expected 21 elements, actual: 3'
      assert_equal expected_message, error.message
    end

    def test_merges_collections_based_on_pattern
      collections = [
        Array.new(20, 'One'),
        Array.new(20, 'Two'),
        Array.new(20, 'Three')
      ]
      expected = %w[One One One One One Two Two Three Three Three One One One One One Two Two Three Three Three One]

      assert_equal expected, @mergifier.merge(*collections)
    end

    def test_returned_collection_has_same_number_of_elements_as_total
      collections = [
        Array.new(20, 'One'),
        Array.new(20, 'Two'),
        Array.new(20, 'Three')
      ]

      assert_equal @mergifier.total, @mergifier.merge(*collections).count
    end

    def test_returns_total_from_collections_if_no_total_present
      mergifier = Merginator::PatternMerge.new(5, 2, 3)
      collections = [
        Array.new(20, 'One'),
        Array.new(20, 'Two'),
        Array.new(20, 'Three')
      ]
      expected_count = collections.flatten.count

      assert_equal expected_count, mergifier.merge(*collections).count
    end

    def test_returns_total_from_collections_if_no_total_present_when_collections_different_lengths
      collections = [
        Array.new(5, 'One'),
        Array.new(20, 'Two'),
        Array.new(15, 'Three')
      ]
      expected_count = collections.flatten.count

      mergifier = Merginator::PatternMerge.new(5, 2, 3)
      assert_equal expected_count, mergifier.merge(*collections).count
    end

    def test_behaves_like_expected_when_first_collection_has_fewer_elements
      collections = [
        Array.new(5, 'One'),
        Array.new(20, 'Two'),
        Array.new(20, 'Three')
      ]
      expected = %w[One One One One One Two Two Three Three Three Two Two Three]
      expected += %w[Three Three Two Two Three Three Three Two]

      assert_equal expected, @mergifier.merge(*collections)
    end

    def test_behaves_like_expected_when_subsequent_collection_has_fewer_elements
      collections = [
        Array.new(20, 'One'),
        Array.new(3, 'Two'),
        Array.new(3, 'Three')
      ]
      expected = %w[One One One One One Two Two Three Three Three One One One One One Two One One One One One]

      assert_equal expected, @mergifier.merge(*collections)
    end

    def test_wraps_elements_in_wrapper
      collections = [
        Array.new(20, 'One'),
        Array.new(20, 'Two'),
        Array.new(20, 'Three')
      ]
      wrapper = KindOfArray.new
      mergifier = Merginator::PatternMerge.new(5, 2, 3, wrapper: wrapper)
      result = mergifier.merge(*collections)

      assert_same wrapper, result
    end

    def test_can_ignore_total_and_merge_all
      collections = [
        Array.new(20, 'One'),
        Array.new(20, 'Two'),
        Array.new(20, 'Three')
      ]
      total = 10
      collections_total = collections.flatten.count
      assert_operator collections_total, :>, total

      mergifier = Merginator::PatternMerge.new(5, 2, 3, total: total)
      result = mergifier.merge(*collections, ignore_total: true)

      assert_operator result.count, :>, total
      assert_equal collections_total, result.count
    end

    def test_ignoring_total_also_disables_num_of_elements_validation
      collections = [
        Array.new(3, 'One'),
        Array.new(3, 'Two'),
        Array.new(3, 'Three')
      ]
      total = 10
      collections_total = collections.sum(&:size)
      assert_operator collections_total, :<, total

      mergifier = Merginator::PatternMerge.new(5, 2, 3, total: total)
      result = mergifier.merge(*collections, ignore_total: true)

      assert_operator result.count, :<, total
      assert_equal collections_total, result.count
    end

    def test_does_not_completely_flatten_array_of_arrays
      collections = [
        Array.new(3, %w[One One]),
        Array.new(3, %w[Two Two]),
        Array.new(3, %w[Three Three])
      ]
      mergifier = Merginator::PatternMerge.new(1, 1, 1, total: 7)
      expected = [
        %w[One One],
        %w[Two Two],
        %w[Three Three],
        %w[One One],
        %w[Two Two],
        %w[Three Three],
        %w[One One]
      ]

      result = mergifier.merge(*collections)
      assert_equal expected, result
    end
  end
end
