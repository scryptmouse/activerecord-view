RSpec.shared_examples_for 'test view creation', creates_test_view: true do
  after(:each) do
    drop_test_view if_exists: true
  end

  context 'and using force: true' do
    subject { -> { build_test_view force: true } }

    desc = metadata[:existing] ? 'drops the original' : 'creates a view'

    it desc do
      is_expected.to_not raise_error
    end
  end

  context 'and no args' do
    subject { -> { build_test_view } }

    if metadata[:existing]
      it 'explodes' do
        is_expected.to raise_error
      end
    else
      it 'creates a view' do
        is_expected.to change { test_view_exists? }.from(false).to(true)
      end
    end
  end

  context 'and using replace: true' do
    subject { -> { build_test_view replace: true } }

    if supports_replace_syntax?
      it 'replaces the original' do
        is_expected.to_not raise_error
      end
    else
      it 'explodes' do
        is_expected.to raise_error ActiveRecord::View::UnsupportedSyntax
      end
    end
  end
end

RSpec.shared_examples_for 'schema specs' do
  context 'when creating a view' do
    context 'from scratch', creates_test_view: true, existing: false

    context 'with an existing view', creates_test_view: true, existing: true do
      before(:each) { build_test_view }
    end
  end

  context 'defining a view body' do
    after(:each) { drop_test_view if_exists: true }

    subject { -> { create_view_with_body(view_body) } }

    context 'with a string', valid_view_body: true, works: true  do
      let(:raw_view_body) { model.build_view.to_sql }
    end

    context 'with #to_sql', valid_view_body: true, works: true do
      let(:raw_view_body) { model.build_view }
    end

    context 'with something invalid', invalid_view_body: true, fails: true do
      let(:raw_view_body) { Object.new }
    end
  end
end

RSpec.shared_examples_for 'testing a view body value', view_as_value: true do
  let(:view_body) { raw_view_body }
end

RSpec.shared_examples_for 'testing a view body proc', view_as_proc: true do
  let(:view_body) { proc { raw_view_body } }
end

RSpec.shared_examples_for 'a valid view body', valid_view_body: true, works: true do
  context 'when passed directly', view_as_value: true do
    it('works', works: true) { is_expected.to_not raise_error }
  end

  context 'with view body as a proc', view_as_proc: true do
    it('works', works: true) { is_expected.to_not raise_error }
  end
end

RSpec.shared_examples_for 'an invalid view body', invalid_view_body: true, fails: true do
  context 'when passed directly', view_as_value: true do
    it('explodes', fails: true) { is_expected.to raise_error }
  end

  context 'with view body as a proc', view_as_proc: true do
    it('explodes', fails: true) { is_expected.to raise_error }
  end
end
