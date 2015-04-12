describe ActiveRecord::View::Integration::SchemaMethods, query_building: true do
  let(:name) { "foo" }
  let(:body) { "SELECT 1" }
  let(:query_args) { Hash.new }

  context 'creating a view', query_type: :create, sqlite3_exception: true do
    let(:query_method) { :build_create_view_query }
    let(:default_sql) { %[CREATE VIEW "#{name}" AS #{body}] }
  end

  context 'creating a materialized view', query_type: :create do
    let(:query_method) { :build_create_materialized_view_query }
    let(:default_sql) { %[CREATE MATERIALIZED VIEW "#{name}" AS #{body} WITH NO DATA] }

    context 'populating with data' do
      before(:each) { query_args.merge! with_data: true }

      specify 'adds WITH DATA' do
        is_expected.to end_with 'WITH DATA'
      end
    end
  end

  context 'dropping a view', query_type: :drop, sqlite3_exception: true do
    let(:query_method) { :build_drop_view_query }
    let(:default_sql) { %[DROP VIEW "#{name}" RESTRICT] }
  end

  context 'dropping a materialized view', query_type: :drop do
    let(:query_method) { :build_drop_materialized_view_query }
    let(:default_sql) { %[DROP MATERIALIZED VIEW "#{name}" RESTRICT] }
  end
end
