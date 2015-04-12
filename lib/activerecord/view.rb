require 'bundler/setup'

require "active_record"
require "virtus"
require "dux"
require "activerecord/view/error"
require "activerecord/view/utility"
require "activerecord/view/version"

require 'activerecord/view/introspection'

require 'activerecord/view/integration'

require 'activerecord/view/read_only'
require 'activerecord/view/view_methods'
require 'activerecord/view/materialized_view_methods'

module ActiveRecord
  module View
    extend ActiveSupport::Concern
    extend Integration
    extend Introspection
  end
end

ActiveSupport.on_load :active_record do
  ActiveRecord::View.enable!
end
