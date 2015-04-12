module ActiveRecord
  module View
    module ViewMethods
      extend ActiveSupport::Concern

      module ClassMethods
        # Get the view's current definition query.
        #
        # @param [Boolean] raise_error
        # @return [String, nil]
        def view_definition(raise_error: false)
          ActiveRecord::View.definition_for self, raise_error: raise_error
        end
      end
    end
  end
end
