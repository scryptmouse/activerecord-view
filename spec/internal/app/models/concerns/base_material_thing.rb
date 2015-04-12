module BaseMaterialThing
  extend ActiveSupport::Concern

  included do
    self.table_name = 'material_things'

    is_materialized_view!
  end
end
