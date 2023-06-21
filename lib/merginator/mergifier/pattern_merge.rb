# frozen_string_literal: true

module Merginator
  module Mergifier
    # Merging based on a given pattern.
    # ex.
    # Merginator::Mergifier::PatternMerge.new(4, 2, 1, total: 25) # Means 3 collections, four from the
    # first, 2 from the second, and one from the third. Also passing in the total,
    # or, an amount for a page
    class PatternMerge
      attr_reader :pattern, :total, :counts

      def initialize(*pattern, total: nil)
        @pattern = pattern
        raise ArgumentError, 'there must be more than one collection in the pattern' if @pattern.count <= 1
        raise ArgumentError, 'pattern must be all integers' unless @pattern.all? { |n| n.is_a? Integer }

        @total = total
        raise ArgumentError, 'total must be at least 1' if @total && @total < 1

        # Counts are helpful when you're looking for a particular length end result
        # and querying a database or index. If you're not, they're not needed.
        @counts = generate_pattern_counts(@total) if @total
      end

      def merge(*collections)
        raise ArgumentError, 'number of collections must match pattern' unless @pattern.count == collections.count

        total = @total || collections.sum(&:count)

        slices = collections.map.with_index do |collection, index|
          collection.each_slice(@pattern[index]).to_a
        end

        slices[0].zip(*slices[1..]).flatten.take(total)
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
    end
  end
end
