class PostgresModel < ActiveRecord::Base
  self.abstract_class = true

  establish_connection :postgresql
end
