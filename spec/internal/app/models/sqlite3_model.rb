class Sqlite3Model < ActiveRecord::Base
  self.abstract_class = true

  establish_connection :sqlite3
end
