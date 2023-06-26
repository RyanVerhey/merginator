# frozen_string_literal: true

require_relative 'merginator/version'
require_relative 'merginator/pattern_merge'

# Contains top-level namespace code
module Merginator
  class Error < StandardError; end

  def self.pattern_merge(...)
    PatternMerge.new(...)
  end
end
