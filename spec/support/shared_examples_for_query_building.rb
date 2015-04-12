RSpec.shared_examples_for 'create view queries', query_type: :create do
  subject { build_default_create_query }

  let(:should_replace)  { false }

  before(:each) do
    query_args.merge! replace: should_replace
  end

  include_examples 'default sql generation'

  context 'with replace: true' do
    let(:should_replace) { true }

    specify 'adds `OR REPLACE` to the SQL' do
      is_expected.to include 'OR REPLACE'
    end

    context 'and sqlite3', set_sqlite3: true do
      specify 'explodes' do
        expect do
          build_default_create_query
        end.to raise_error ActiveRecord::View::UnsupportedSyntax
      end
    end if metadata[:sqlite3_exception]
  end
end

RSpec.shared_context 'query building', query_building: true do
  let(:should_force) { false }

  before(:each) { query_args.merge! force: should_force }
end

RSpec.shared_examples_for 'drop view queries', query_type: :drop do
  subject { build_default_drop_query }

  include_examples 'default sql generation'

  context 'when forced' do
    let(:should_force) { true }

    specify 'will CASCADE' do
      is_expected.to end_with 'CASCADE'
    end

    context 'and sqlite3', set_sqlite3: true do
      specify 'ignores force' do
        is_expected.to end_with %["#{name}"]
      end
    end if metadata[:sqlite3_exception]
  end

  context 'only if exists' do
    before(:each) { query_args.merge! if_exists: true }

    specify 'will drop only IF EXISTS' do
      is_expected.to include 'IF EXISTS'
    end
  end
end

RSpec.shared_context 'for merging sqlite3', set_sqlite3: true do
  before(:each) { query_args.merge! sqlite3: true }
end

RSpec.shared_examples_for 'default sql generation', default_sql: true do
  specify 'generates the correct SQL' do
    is_expected.to eq default_sql
  end
end
