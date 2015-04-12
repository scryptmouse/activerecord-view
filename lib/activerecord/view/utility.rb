module ActiveRecord
  module View
    module Utility
      # Strip newlines and excess whitespace from SQL statements
      module_function

      def cleanup(raw_sql)
        raw_sql.strip.gsub /\n\s+/, ' '
      end
    end
  end
end
