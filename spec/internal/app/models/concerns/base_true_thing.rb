module BaseTrueThing
  extend ActiveSupport::Concern

  included do
    self.table_name = 'true_things'

    is_view!
  end
end
