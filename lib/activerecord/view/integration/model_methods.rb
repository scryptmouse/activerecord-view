module ActiveRecord
  module View
    module Integration
      module ModelMethods
        # @return [void]
        def is_view!(readonly: true, **kwargs)
          include ActiveRecord::View::ViewMethods
          include ActiveRecord::View::ReadOnly if readonly
        end

        def is_materialized_view!(**kwargs)
          is_view!(**kwargs)

          include ActiveRecord::View::MaterializedViewMethods
        end

        def materialized_view?
          self < ActiveRecord::View::MaterializedViewMethods
        end

        def view?
          self < ActiveRecord::View::ViewMethods
        end
      end
    end
  end
end
