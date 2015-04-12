module DBHelper
  def view_name
    :true_things
  end

  def materialized_view_name
    :material_things
  end

  class Abstract < Module
    module BaseMethods
      def connection
        model.connection
      end

      def sqlite3?
        prefix =~ /sqlite3/i
      end

      def supports_replace_syntax?
        !sqlite3?
      end
    end

    def initialize(prefix, &block)
      super() if defined?(super)

      define_method(:prefix) { prefix }

      class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def model
        ::#{prefix}Thing
      end

      def view
        ::#{prefix}TrueThing
      end
      RUBY

      instance_exec(&block) if block_given?

      include BaseMethods
    end

    def included(base)
      base.extend self
    end
  end

  MySQL   = Abstract.new 'Mysql'

  PG      = Abstract.new 'Postgres' do
    def materialized_view
      PostgresMaterialThing
    end
  end

  SQLite3 = Abstract.new 'Sqlite3'
end

RSpec.configure do |config|
  config.include DBHelper
  config.include DBHelper::MySQL,   mysql: true
  config.include DBHelper::PG,      pg: true
  config.include DBHelper::SQLite3, sqlite3: true
end
