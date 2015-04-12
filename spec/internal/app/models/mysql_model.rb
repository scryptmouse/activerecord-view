class MysqlModel < ActiveRecord::Base
  self.abstract_class = true

  establish_connection :mysql
end
