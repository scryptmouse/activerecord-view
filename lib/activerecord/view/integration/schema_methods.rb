module ActiveRecord
  module View
    module Integration
      module SchemaMethods
        extend ActiveSupport::Concern
        extend ActiveRecord::View::Utility

        CREATE_VIEW_FMT = cleanup <<-SQL
        CREATE%<or_replace>s VIEW %<name>s AS %<body>s
        SQL

        DROP_VIEW_FMT = cleanup <<-SQL
        DROP VIEW%<if_exists>s %<name>s%<restriction>s
        SQL

        CREATE_MATERIALIZED_VIEW_FMT = cleanup <<-SQL
        CREATE%<or_replace>s MATERIALIZED VIEW %<name>s AS %<body>s %<with_data>s
        SQL

        DROP_MATERIALIZED_VIEW_FMT = cleanup <<-SQL
        DROP MATERIALIZED VIEW%<if_exists>s %<name>s%<restriction>s
        SQL

        MATERIALIZED_VIEW_ADAPTERS = %w[PostgreSQL PostGIS]

        # Create a SQL view.
        #
        # @param (see #build_create_view_query)
        # @return [void]
        def create_view(name, body = nil, force: false, **kwargs, &block)
          kwargs[:sqlite3] = !!(adapter_name =~ /sqlite/i)

          drop_view(name) if force && table_exists?(name)

          execute build_create_view_query(name, body, **kwargs, &block)
        end

        # Drop a SQL view.
        #
        # @param (see #build_drop_view_query)
        # @return [void]
        def drop_view(name, **kwargs)
          kwargs[:sqlite3] = !!(adapter_name =~ /sqlite/i)

          execute build_drop_view_query(name, **kwargs)
        end

        # Create a materialized view.
        #
        # Only valid on Postgres.
        #
        # @param (see #build_create_materialized_view_query)
        # @return [void]
        def create_materialized_view(name, body = nil, force: false, **kwargs, &block)
          supports_materialized_view!

          drop_materialized_view(name) if force && table_exists?(name)

          execute build_create_materialized_view_query(name, body, **kwargs, &block)
        end

        # Drop a materialized view.
        #
        # Only valid on Postgres.
        #
        # @param (see #build_drop_materialized_view_query)
        # @return [void]
        def drop_materialized_view(name, **kwargs)
          supports_materialized_view!

          execute build_drop_materialized_view_query(name, **kwargs)
        end

        protected
        # @raise [ActiveRecord::View::MaterializedViewNotSupported] if unsupported
        # @return [void]
        def supports_materialized_view!
          raise ActiveRecord::View::MaterializedViewNotSupported, adapter_name unless MATERIALIZED_VIEW_ADAPTERS.include?(adapter_name)
        end

        module_function
        # @param [#to_s] name
        # @param [String, #to_sql] body
        # @param [Boolean] replace
        # @param [Boolean] with_data Whether the materialized view should be automatically populated on create.
        # @yieldreturn [String, #to_sql] alternatively the body can be provided in a block
        # @return [String]
        def build_create_materialized_view_query(name, body, force: nil, replace: false, with_data: false, &block)
          options = {
            or_replace: replace ? ' OR REPLACE' : '',
            with_data:  with_data ? 'WITH DATA' : 'WITH NO DATA',
            name:       quote_table_name(name)
          }

          options[:body] = fetch_view_body(body, &block)

          sprintf CREATE_MATERIALIZED_VIEW_FMT, options
        end

        # @param [#to_s] name
        # @param [String, #to_sql] body
        # @param [Boolean] replace
        # @param [Boolean] sqlite3 whether this should be built for SQLite3 (SQLite3 does not support `OR REPLACE` syntax)
        # @yieldreturn [String, #to_sql] alternatively the body can be provided in a block
        # @return [String]
        def build_create_view_query(name, body, force: nil, replace: false, sqlite3: false, &block)
          options = {
            or_replace: replace ? ' OR REPLACE' : '',
            name:       quote_table_name(name)
          }

          options[:or_replace] = unless sqlite3
                                   replace ? ' OR REPLACE' : ''
                                 else
                                   raise ActiveRecord::View::UnsupportedSyntax, 'SQLite3 does not support `OR REPLACE` syntax' if replace
                                   ''
                                 end

          options[:body] = fetch_view_body(body, &block)

          sprintf CREATE_VIEW_FMT, options
        end

        # @return [String]
        def build_drop_materialized_view_query(name, if_exists: false, force: false, **kwargs)
          options = {
            if_exists:  if_exists ? ' IF EXISTS' : '',
            name:       quote_table_name(name)
          }

          options[:restriction] = force ? ' CASCADE' : ' RESTRICT'

          sprintf DROP_MATERIALIZED_VIEW_FMT, options
        end

        # @return [String]
        def build_drop_view_query(name, if_exists: false, force: false, sqlite3: false, **kwargs)
          options = {
            if_exists:  if_exists ? ' IF EXISTS' : '',
            name:       quote_table_name(name)
          }

          options[:restriction] = unless sqlite3
                                    force ? ' CASCADE' : ' RESTRICT'
                                  else
                                    ''
                                  end

          sprintf DROP_VIEW_FMT, options
        end

        # @api private
        # @param [String, #to_sql, nil] body
        # @yieldreturn [String, #to_sql] alternatively the body can be provided in a block
        # @return [String]
        def fetch_view_body(body, &block)
          body ||= yield if block_given?

          raise 'Must provide body to to create a view' if body.blank?

          body &&= body.to_sql if body.respond_to? :to_sql

          body
        end

        class << self
          # @api private
          # Stub method for tests.
          # @param [String] name
          # @return [String]
          def quote_table_name(name)
            %["#{name}"]
          end
        end
      end
    end
  end
end
