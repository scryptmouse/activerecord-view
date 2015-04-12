module ActiveRecord
  module View
    module Introspection

      # @abstract
      # @api private
      class Abstract
        extend ActiveModel::Callbacks
        include Virtus.model strict: true

        define_model_callbacks :fetch_view_definition

        delegate :adapter_name, :current_database, :select_value, :select_all, to: :connection

        attribute :connection,  Connectible, default: :default_connection
        attribute :raise_error, Boolean, default: false

        # @abstract
        # @return [<ActiveRecord::View::Introspection::ViewDefinition>]
        def views
        end

        # @param [String] view_name
        # @param [Hash] options
        # @option options [Boolean] :pretty whether the SQL definition should be pretty-printed. Only works in postgres.
        # @return [String]
        def definition_for(view_name, **options)
          run_callbacks :fetch_view_definition do
            result = select_value fetch_view_definition_query(view_name, **options)

            process_view_definition(result).tap do |processed|
              raise ActiveRecord::View::Error, 'Empty Definition' if raise_error? && processed.blank?
            end
          end
        end

        # @return [Arel::SelectManager]
        def select_manager
          Arel::SelectManager.new self
        end

        # @param [String]
        # @return [String]
        def process_view_definition(result)
          result
        end
        
        # @api private
        # @abstract
        # @param [String] view_name
        # @return [Arel::SelectManager]
        def fetch_view_definition_query(view_name, **options)
          # :nocov:
          raise NotImplementedError, "Must implement for #{self.class}"
          # :nocov:
        end

        def inspect
          # :nocov:
          "<#{self.class.name}(:raise_error => #{raise_error?})>"
          # :nocov:
        end

        # Build a SQL-compliant cast statement
        #
        # @param [String, Arel::Nodes::Quoted] value
        # @param [String, Arel::Nodes::SqlLiteral] type
        # @return [Arel::Nodes::NamedFunction("CAST", [Arel::Nodes::As(Arel::Nodes::Quoted, Arel::Nodes::SqlLiteral)])]
        def arel_cast(value, type, quote_value: true, literalize_type: true)
          value = arel_quoted(value)  if quote_value
          type  = Arel.sql(type)      if literalize_type

          as_expr = Arel::Nodes::As.new value, type

          arel_fn 'CAST', as_expr
        end

        # Build an Arel function
        #
        # @return [Arel::Nodes::NamedFunction]
        def arel_fn(name, *args)
          Arel::Nodes::NamedFunction.new(name, args)
        end

        # Build a quoted string
        #
        # @return [Arel::Nodes::Quoted]
        def arel_quoted(value)
          arel_quoted?(value) ? value : Arel::Nodes.build_quoted(value)
        end

        def arel_quoted?(value)
          value.kind_of? Arel::Nodes::Quoted
        end

        # @api private
        # @return [ActiveRecord::ConnectionAdapters::AbstractAdapter]
        def default_connection
          # :nocov:
          ActiveRecord::Base.connection
          # :nocov:
        end
      end
    end
  end
end
