module ActiveRecord
  module View
    module Introspection
      class SQLite3 < Abstract
        SQL_DEFINITION = /\ACREATE\s+VIEW.+?\bAS\b\s+(.+)\z/i

        def process_view_definition(result)
          return result if result.blank?

          result[SQL_DEFINITION, 1]
        end

        def fetch_view_definition_query(view_name, **options)
          master_table.project(sql_definition).where(type_is_view.and(view_name_eq(view_name)))
        end

        # @!attribute [r] master_table
        # @return [Arel::Table]
        def master_table
          @_master_table ||= Arel::Table.new 'sqlite_master', self
        end

        def sql_definition
          master_table[:sql]
        end

        def view_name_eq(name)
          master_table[:name].eq(name)
        end

        # @return [Arel::Nodes::Equality]
        def type_is_view
          master_table[:type].eq('view')
        end
      end
    end
  end
end
