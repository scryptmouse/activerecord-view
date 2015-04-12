module ActiveRecord
  module View
    # @api private
    module ReadOnly
      extend ActiveSupport::Concern

      READONLY_CLASS_METHODS = %i[destroy destroy_all delete delete_all update_all update]

      included do
        before_destroy :indestructibly_readonly!

        relation.class.prepend ActiveRecord::View::ReadOnly::ClassMethods
      end

      def readonly?
        true
      end

      def delete
        raise ActiveRecord::ReadOnlyRecord
      end

      protected
      def indestructibly_readonly!
        raise ActiveRecord::ReadOnlyRecord
      end

      module ClassMethods
        def attempt_update(*args)
          raise ActiveRecord::ReadOnlyRecord, "This is a read-only view"
        end

        READONLY_CLASS_METHODS.each do |m|
          alias_method m, :attempt_update
        end
      end
    end
  end
end
