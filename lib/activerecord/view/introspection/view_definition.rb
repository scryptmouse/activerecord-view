module ActiveRecord
  module View
    module Introspection
      class ViewDefinition
        include Virtus.value_object strict: true

        values do
          attribute :name,          String
          attribute :definition,    String
          attribute :adapter,       String
          attribute :materialized,  Boolean, default: false
        end

        alias_method :sql, :definition
      end
    end
  end
end
