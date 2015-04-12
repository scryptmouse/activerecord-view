module ActiveRecord
  module View
    module Introspection
      class MySQL < Abstract
        def fetch_view_definition_query(view_name, **options)
          schema_table.project(schema_definition).where(in_current_database.and(view_name_eq(view_name)))
        end

        # @!attribute [r] schema_table
        # @return [Arel::Table]
        def schema_table
          @_schema_table ||= Arel::Table.new 'information_schema.views', self
        end

        def schema_definition
          schema_table['view_definition']
        end

        def view_name_eq(name)
          schema_table['table_name'].eq(name)
        end

        def in_current_database
          schema_table['table_schema'].eq(current_database)
        end
      end
    end
  end
end
