# frozen_string_literal: true

require 'test_helper'

class TestPatternMerge < Minitest::Test
  class Initialize < TestPatternMerge
    def test_more_than_one_pattern_required
      error = assert_raises ArgumentError do
        Merginator::Mergifier::PatternMerge.new(1)
      end

      expected_message = 'there must be more than one collection in the pattern'
      assert_equal expected_message, error.message
    end

    def test_pattern_must_be_all_integers
      error = assert_raises ArgumentError do
        Merginator::Mergifier::PatternMerge.new('1', '2')
      end

      expected_message = 'pattern must be all integers'
      assert_equal expected_message, error.message
    end

    def test_total_not_required
      # assert_nothing_raised
      Merginator::Mergifier::PatternMerge.new(1, 2)

      # assert_nothing_raised
      Merginator::Mergifier::PatternMerge.new(1, 2, total: 5)
    end

    def test_total_must_be_ge_one
      error = assert_raises ArgumentError do
        Merginator::Mergifier::PatternMerge.new(1, 2, total: 0)
      end

      expected_message = 'total must be at least 1'
      assert_equal expected_message, error.message
    end

    def test_generates_counts_if_total_present
      no_counts = Merginator::Mergifier::PatternMerge.new(1, 2)
      refute no_counts.counts

      yes_counts = Merginator::Mergifier::PatternMerge.new(1, 2, total: 10)
      assert yes_counts.counts
    end
  end

  class Counts < TestPatternMerge
    def test_generates_pattern_counts_properly
      mergifier = Merginator::Mergifier::PatternMerge.new(5, 2, 3, total: 21)
      expected = [11, 4, 6]

      assert_equal expected, mergifier.counts

      mergifier = Merginator::Mergifier::PatternMerge.new(3, 10, 3, total: 30)
      expected = [6, 20, 4]

      assert_equal expected, mergifier.counts

      mergifier = Merginator::Mergifier::PatternMerge.new(1, 2, 3, total: 30)
      expected = [5, 10, 15]

      assert_equal expected, mergifier.counts

      mergifier = Merginator::Mergifier::PatternMerge.new(50, 20, 10, total: 300)
      expected = [200, 70, 30]

      assert_equal expected, mergifier.counts
    end
  end

  class Merge < TestPatternMerge
    def setup
      super

      @mergifier = Merginator::Mergifier::PatternMerge.new(5, 2, 3, total: 21)
    end

    def test_number_of_collections_must_match_pattern_length
      collections = [[1], [2]]
      refute collections.count == @mergifier.pattern.count

      error = assert_raises ArgumentError do
        @mergifier.merge(*collections)
      end

      expected_message = 'number of collections must match pattern; expected 3 collections, actual: 2'
      assert_equal expected_message, error.message
    end

    def test_number_of_elements_must_be_gte_total
      collections = [[1], [2], [3]]
      refute collections.flatten.count >= @mergifier.total

      error = assert_raises ArgumentError do
        @mergifier.merge(*collections)
      end

      expected_message = 'total number of elements in collections must be >= provided total; expected 21 elements, actual: 3'
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
      mergifier = Merginator::Mergifier::PatternMerge.new(5, 2, 3)
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

      assert_equal expected_count, @mergifier.merge(*collections).count
    end

    def test_behaves_like_expected_when_first_collection_has_fewer_elements
      collections = [
        Array.new(5, 'One'),
        Array.new(20, 'Two'),
        Array.new(20, 'Three')
      ]
      expected = %w[One One One One One Two Two Three Three Three Two Two Three Three Three Two Two Three Three Three Two]

      assert_equal expected, @mergifier.merge(*collections)
    end

    def test_behaves_like_expected_when_subsequent_collection_has_fewer_elements
      collections = [
        Array.new(20, 'One'),
        Array.new(3, 'Two'),
        Array.new(3, 'Three')
      ]
      expected = %w[One One One One One Two Two Three Three Three One One One One One Two One One One One]

      assert_equal expected, @mergifier.merge(*collections)
    end
  end
end
