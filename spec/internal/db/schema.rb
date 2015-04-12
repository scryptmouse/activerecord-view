ActiveRecord::Schema.define do
  create_table :things, force: true do |t|
    t.string :name
    t.boolean :veracity, null: false, default: false
  end
end

TEST_MODELS = [PostgresThing, MysqlThing, Sqlite3Thing]

TEST_MODELS.each do |model|
  model.connection.create_table :things, force: :cascade do |t|
    t.string :name
    t.boolean :veracity, null: false, default: false
  end
end
