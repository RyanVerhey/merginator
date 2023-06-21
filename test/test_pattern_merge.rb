# frozen_string_literal: true

require 'test_helper'

class TestPatternMerge < Minitest::Test
  class Initialize < TestPatternMerge
    def test_more_than_one_pattern_required
      skip 'TBD'
    end

    def test_pattern_must_be_all_integers
      skip 'TBD'
    end

    def test_total_not_required
      skip 'TBD'
    end

    def test_total_must_be_ge_one
      skip 'TBD'
    end

    def test_generates_counts_if_total_present
      skip 'TBD'
    end
  end

  class Merge < TestPatternMerge
    def test_number_of_collections_must_match_pattern_length
      skip 'TBD'
    end

    def test_merges_collections_based_on_pattern
      skip 'TBD'
    end

    def test_returned_collection_has_same_number_of_elements_as_total
      skip 'TBD'
    end

    def test_returns_total_from_collection_if_no_total_present
      skip 'TBD'
    end
  end
end
