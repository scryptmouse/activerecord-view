module ActiveRecord
  module View
    module MaterializedViewMethods
      extend ActiveSupport::Concern

      REFRESH_QUERY = %[REFRESH MATERIALIZED VIEW %s]

      module ClassMethods
        def refresh_view_query
          sprintf REFRESH_QUERY, quoted_table_name
        end

        def refresh_view!
          connection.execute refresh_view_query
        end
      end
    end
  end
end
