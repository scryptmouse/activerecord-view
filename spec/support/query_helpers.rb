module QueryHelpers
  def build_query(*args, **kwargs)
    described_class.__send__(query_method, *args, **kwargs)
  end

  def build_default_create_query
    build_query name, body, **query_args
  end

  def build_default_drop_query
    build_query name, **query_args
  end
end

RSpec.configure do |config|
  config.include QueryHelpers, query_building: true
end
