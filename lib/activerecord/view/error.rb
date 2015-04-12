module ActiveRecord
  module View
    # @api private
    class Error < StandardError; end

    # @api private
    class MaterializedViewNotSupported < Error
      def initialize(adapter)
        super("Materialized views are not supported by `#{adapter}`")
      end
    end

    # @api private
    class UnsupportedDatabase < Error; end

    # @api private
    class UnsupportedSyntax < ActiveRecord::View::Error; end
  end
end
