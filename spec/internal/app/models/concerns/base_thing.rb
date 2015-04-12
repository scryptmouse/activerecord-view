module BaseThing
  extend ActiveSupport::Concern

  included do
    self.table_name = 'things'

    scope :truthy, -> { where(veracity: true ) }
  end

  module ClassMethods
    # @return [Arel::SelectManager]
    def build_view
      arel_table.where(arel_table[:veracity].eq(true)).project('*')
    end

    def model_prefix
      name[/\A(\w+)Thing\z/, 1]
    end

    def view_klass
      "#{model_prefix}TrueThing".constantize
    end

    def materialized_view_klass
      "#{model_prefix}MaterialThing".safe_constantize
    end

    def create_materialized_view!
      connection.create_materialized_view :material_things, build_view, force: true, with_data: true
    end

    def create_view!
      connection.create_view :true_things, build_view, force: true
    end

    def drop_materialized_view!
      connection.drop_view :material_things, if_exists: true
    end

    def drop_view!
      connection.drop_view :true_things, if_exists: true
    end
  end
end
