# frozen_string_literal: true

module Merginator
  # Merging based on a given pattern.
  # ex.
  # Merginator::PatternMerge.new(4, 2, 1, total: 25) # Means 3 collections, four from the
  # first, 2 from the second, and one from the third. Also passing in the total,
  # or, an amount for a page
  class PatternMerge
    attr_reader :pattern, :total, :counts

    def initialize(*pattern, total: nil)
      @pattern = pattern
      validate_pattern

      @total = total
      validate_total

      # Counts are helpful when you're looking for a particular length end result
      # and querying a database or index. If you're not, they're not needed.
      @counts = generate_pattern_counts(@total) if @total
    end

    def merge(*collections)
      validate_merge_collections(collections)

      total = @total || collections.sum(&:size)

      slices_for_collections = collections.map.with_index do |collection, index|
        collection.each_slice(@pattern[index]).to_a
      end

      slices_for_collections.map(&:size).max.times.each_with_object([]) do |index, arr|
        arr << slices_for_collections.map { |slices| slices[index] || [] }.flatten
        break(arr) if arr.flatten.size >= total
      end.flatten.take(total)
    end

    private

    # Outputs the counts needed for each collection in the pattern to reach the
    # provided total
    # ex:
    # Merginator::Mergifier::PatternMerge.new(4, 2, 1, total: 25)
    # => [16, 6, 3]
    def generate_pattern_counts(total)
      full_repetitions = total / @pattern.sum
      counts = @pattern.map { |num| num * full_repetitions }

      @pattern.each_with_index do |num, index|
        # Add the difference between the total and the current total, up to
        # the pattern number

        counts[index] += (total - counts.sum).clamp(0, num)
      end

      counts
    end

    def validate_pattern
      raise ArgumentError, 'there must be more than one collection in the pattern' if @pattern.count <= 1
      raise ArgumentError, 'pattern must be all integers' unless @pattern.all? { |n| n.is_a? Integer }
    end

    def validate_total
      raise ArgumentError, 'total must be at least 1' if @total && @total < 1
    end

    def validate_merge_collections(collections)
      unless @pattern.count == collections.count
        message = 'number of collections must match pattern; '
        message += "expected #{@pattern.count} collections, actual: #{collections.count}"
        raise ArgumentError, message
      end

      if @total && collections.flatten.count < @total
        message = 'total number of elements in collections must be >= provided total; '
        message += "expected #{@total} elements, actual: #{collections.flatten.count}"
        raise ArgumentError, message
      end
    end
  end
end
