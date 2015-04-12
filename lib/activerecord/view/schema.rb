module ActiveRecord
  module View
    # Namespace for schema / migration logic
    module Schema
      %w[abstract].each do |mod|
        require "activerecord/view/schema/#{mod}"
      end
    end
  end
end
