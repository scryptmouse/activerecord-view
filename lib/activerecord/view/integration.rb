module ActiveRecord
  module View
    module Integration
      AR_INCLUSIONS = {
        'SchemaMethods' => 'ActiveRecord::ConnectionAdapters::AbstractAdapter',
        'CommandRecorderMethods' => 'ActiveRecord::Migration::CommandRecorder'
      }

      AR_EXTENSIONS = {
        'ModelMethods' => 'ActiveRecord::Base'
      }

      def enable!
        AR_INCLUSIONS.each do |mod_name, target|
          target_klass = target.constantize
          mod = "ActiveRecord::View::Integration::#{mod_name}".constantize

          target_klass.include mod
        end

        AR_EXTENSIONS.each do |mod_name, target|
          target_klass = target.constantize
          mod = "ActiveRecord::View::Integration::#{mod_name}".constantize

          target_klass.extend mod
        end

        #ActiveRecord::ConnectionAdapters::AbstractAdapter.include ActiveRecord::View::Integration::SchemaMethods
        #ActiveRecord::Base.extend ActiveRecord::View::Integration::ModelMethods
        #ActiveRecord::Migration::CommandRecorder.include ActiveRecord::View::
      end

      require_relative './integration/command_recorder_methods'
      require_relative './integration/model_methods'
      require_relative './integration/schema_methods'
    end
  end
end
