RSpec.shared_context 'default view' do
  before(:context) do
    connection.create_view view_name, model.build_view, force: true
  end

  after(:context) do
    connection.drop_view view_name, if_exists: true
  end
end

RSpec.shared_context 'default materialized view' do
  let(:build_with_data) { false }
  let(:force_drop) { false }

  before(:each) do
    connection.create_materialized_view materialized_view_name, model.build_view, force: true, with_data: build_with_data
  end

  after(:each) do
    connection.drop_materialized_view view_name, if_exists: true, force: force_drop
  end
end

RSpec.shared_context 'test materialized view', test_materialized_view: true do
  subject { -> { build_test_materialized_view } }
end
