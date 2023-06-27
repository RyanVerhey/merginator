# frozen_string_literal: true

module Merginator
  # Merging based on a given pattern.
  # ex.
  # Merginator::PatternMerge.new(4, 2, 1, total: 25) # Means 3 collections, four from the
  # first, 2 from the second, and one from the third. Also passing in the total,
  # or, an amount for a page
  class PatternMerge
    attr_reader :pattern, :total, :counts, :wrapper

    def initialize(*pattern, total: nil, wrapper: [])
      @pattern = pattern
      validate_pattern

      @total = total
      validate_total

      @wrapper = wrapper
      validate_wrapper

      # Counts are helpful when you're looking for a particular length end result
      # and querying a database or index. If you're not, they're not needed.
      @counts = generate_pattern_counts(@total) if @total
    end

    def merge(*collections, wrapper: @wrapper, ignore_total: false)
      validate_merge_collections(collections)
      validate_wrapper wrapper

      total = ignore_total || !@total ? collections.sum(&:size) : @total

      slices_for_collections = slice_collections(collections)
      merge_collections_into_wrapper(slices_for_collections, wrapper: wrapper, total: total)

      wrapper
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

    def slice_collections(collections)
      collections.map.with_index do |collection, index|
        collection.each_slice(@pattern[index]).to_a
      end
    end

    def merge_collections_into_wrapper(slices_for_collections, wrapper:, total:)
      slices_for_collections.map(&:size).max.times.each_with_object(wrapper) do |index, wrapper_obj|
        wrapper_obj.concat slices_for_collections.map { |slices| slices[index] || [] }.flatten
        break(wrapper_obj) if wrapper_obj.size >= total
      end

      wrapper.replace wrapper.take(total)
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

      return unless @total && collections.flatten.count < @total

      message = 'total number of elements in collections must be >= provided total; '
      message += "expected #{@total} elements, actual: #{collections.flatten.count}"
      raise ArgumentError, message
    end

    def validate_wrapper(wrapper = @wrapper)
      return if wrapper.is_a?(Enumerable)

      raise ArgumentError, 'wrapper must be enumerable'
    end
  end
end
