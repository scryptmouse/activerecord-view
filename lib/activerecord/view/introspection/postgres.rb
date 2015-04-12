module ActiveRecord
  module View
    module Introspection
      class Postgres < Abstract
        REGCLASS    = Arel.sql 'regclass'
        PG_TRUE     = Arel.sql 'true'
        PG_FALSE    = Arel.sql 'false'
        NOT_A_VIEW  = Arel::Nodes.build_quoted 'Not a view'

        around_fetch_view_definition :catch_undefined_table

        def fetch_view_definition_query(view_name, **options)
          select_manager.project nullify_if_not_view pg_get_viewdef(view_name, **options)
        end

        # @api private
        # @return [Arel::Nodes::NamedFunction]
        def pg_get_viewdef(view_name, pretty: false, **options)
          pretty_bool = pretty ? PG_TRUE : PG_FALSE

          arel_fn 'pg_get_viewdef', arel_cast(view_name, REGCLASS), pretty_bool
        end

        # @api private
        # @return [Arel::Nodes::NamedFunction]
        def nullify_if_not_view(expression)
          arel_fn 'NULLIF', expression, NOT_A_VIEW
        end

        # @api private
        def catch_undefined_table
          yield
        rescue ActiveRecord::StatementInvalid => e
          if e.original_exception.kind_of? PG::UndefinedTable
            raise e if raise_error?

            nil
          else
            # :nocov:
            raise e
            # :nocov:
          end
        end
      end
    end
  end
end
