class Thing < ActiveRecord::Base
  class << self
    # @return [Arel::SelectManager]
    def build_view
      arel_table.where(arel_table[:veracity].eq(true))
    end
  end
end
