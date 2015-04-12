module ActiveRecord
  module View
    module Introspection
      # @overload definition_for(name, connection:)
      #   @param [String] name
      #   @param [ActiveRecord::ConnectionAdapters::AbstractAdapter] connection
      # @overload definition_for(model, connection: nil)
      #   @param [#connection, ActiveRecord::View] model
      #   @param [ActiveRecord::ConnectionAdapters::AbstractAdapter] connection
      # @return [String]
      def definition_for(model_or_name, connection: nil, raise_error: false)
        view_name, connection = detect_view_and_connection(model_or_name, connection)

        introspector = introspector_for(connection, raise_error: raise_error)

        introspector.definition_for view_name
      end

      # @param [Class] connection
      # @return [ActiveRecord::View::Introspection::Abstract]
      def introspector_for(connection, raise_error: false)
        connection = connection.connection if connection.respond_to?(:connection)

        klass = case connection.adapter_name
                when /mysql/i           then 'MySQL'
                when /postg(res|gis)/i  then 'Postgres'
                when /sqlite/i          then 'SQLite3'
                else
                  raise ActiveRecord::View::UnsupportedDatabase, "`#{connection.adapter_name}` is not a supported adapter"
                end

        "ActiveRecord::View::Introspection::#{klass}".constantize.new connection: connection, raise_error: raise_error
      end

      # @api private
      # @param [Class, Arel::Table, String] model_or_name
      # @param [ActiveRecord::ConnectionAdapters::AbstractAdapter, nil] connection
      # @return [(String, ActiveRecord::ConnectionAdapters::AbstractAdapter)]
      def detect_view_and_connection(model_or_name, connection)
        view_name = case model_or_name
                    when String, Symbol
                      model_or_name.to_s
                    when IS_MODEL
                      model_or_name.table_name
                    when Arel::Table
                      model_or_name.name
                    end

        connection = coerce_connection(connection.presence || model_or_name)

        raise Error, "Could not derive view name from provided: #{model_or_name.inspect}"   unless view_name.present?
        raise Error, "Could not derive connection from provided: #{model_or_name.inspect}"  unless connection.present?

        return [view_name, connection]
      end

      # @param [Class#connection, Arel::Table, ActiveRecord::ConnectionAdapters::AbstractAdapter]
      # @return [ActiveRecord::ConnectionAdapters::AbstractAdapter]
      def coerce_connection(connectible)
        connection_coercer.coerce connectible
      end

      def connection_coercer
        @_connection_coercer ||= Connectible.new Axiom::Types::Object, default_value: nil, coercer: nil
      end

      # @param [#to_sql, String] body
      # @yieldreturn [#to_sql, String]
      # @return [#to_sql, String]
      def validate_body(body = nil, &block)
        body if valid_body?(body, &block)
      end

      def valid_body?(body)
        body.is_a?(String) || body.respond_to?(:to_sql) || block_given?
      end

      IS_MODEL = ->(klass) { klass.is_a?(Class) && ActiveRecord::Base > klass }

      # @api private
      class Connectible < Virtus::Attribute
        def coerce(value)
          case value
          when ActiveRecord::ConnectionAdapters::AbstractAdapter then value
          when Arel::Table      then value.engine.connection
          when Dux[:connection] then value.connection
          else
            nil
          end
        end
      end

      require_relative './introspection/abstract'
      require_relative './introspection/mysql'
      require_relative './introspection/postgres'
      require_relative './introspection/sqlite3'
      require_relative './introspection/view_definition'
    end
  end
end
