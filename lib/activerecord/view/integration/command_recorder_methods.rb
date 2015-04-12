module ActiveRecord
  module View
    module Integration
      module CommandRecorderMethods
        CREATE_VIEW_METHODS = %i[create_view create_materialized_view]

        DROP_VIEW_METHODS = %i[drop_view drop_materialized_view]

        VIEW_METHOD_PAIRS = Hash[CREATE_VIEW_METHODS.zip(DROP_VIEW_METHODS)].tap do |hsh|
          hsh.merge!(hsh.invert)
        end

        VIEW_METHODS = CREATE_VIEW_METHODS + DROP_VIEW_METHODS

        VIEW_METHODS.each do |method_name|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{method_name}(*args, &block)
            record(:#{method_name}, args, &block)
          end
          RUBY
        end

        CREATE_VIEW_METHODS.each do |method_name|
          inverse_method = VIEW_METHOD_PAIRS.fetch method_name

          class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def invert_#{method_name}(args, &block)
            view_name = args.first

            [:#{inverse_method}, [view_name]]
          end
          RUBY
        end

        DROP_VIEW_METHODS.each do |method_name|
          inverse_method = VIEW_METHOD_PAIRS.fetch method_name

          class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def invert_#{method_name}(args, &block)
            options = args.extract_options!

            view_name = args.shift
            view_body = ActiveRecord::View.validate_body(args.shift, &block)


            unless view_body.present? || block_given?
              raise ActiveRecord::IrreversibleMigration, "To avoid mistakes, #{method_name} is only reversible if provided with a view body or a block."
            end

            args = [view_name]
            args << view_body if view_body.present?
            args << options

            [:#{inverse_method}, args, block]
          end
          RUBY
        end
      end
    end
  end
end
