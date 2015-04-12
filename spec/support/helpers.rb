module ViewHelpers
  delegate :table_exists?, to: :connection

  def test_view_name
    :test_view
  end

  def test_materialized_view_name
    :test_materialized_view
  end

  def test_view_exists?
    table_exists? test_view_name
  end

  def test_materialized_view_exists?
    table_exists? test_materialized_view_name
  end

  def test_view_body
    model.build_view
  end

  def build_test_view(**options)
    connection.create_view test_view_name, test_view_body, **options
  end

  def build_test_materialized_view(**options)
    connection.create_materialized_view test_materialized_view_name, test_view_body, **options
  end

  def drop_test_materialized_view(**options)
    connection.drop_materialized_view test_materialized_view_name, **options
  end

  def create_view_with_body(body, **options)
    if body.kind_of?(Proc)
      connection.create_view test_view_name, **options, &body
    else
      connection.create_view test_view_name, body, **options
    end
  end

  def drop_test_view(**options)
    connection.drop_view test_view_name, **options
  end

  def create_two_things!
    model.create! name: 'foo', veracity: true
    model.create! name: 'bar', veracity: false
  end
end

RSpec.configure do |config|
  config.include ViewHelpers
end
