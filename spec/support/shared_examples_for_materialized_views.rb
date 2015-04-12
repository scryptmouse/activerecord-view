RSpec.shared_examples_for 'adapters that support materialized views', materialized: true do
  context 'materialized views', test_materialized_view: true do
    after(:each) { drop_test_materialized_view(if_exists: true) }

    specify 'are supported' do
      is_expected.to change { test_materialized_view_exists? }.from(false).to(true)
    end
  end

  context 'materialized view models' do
    include_context 'default materialized view'

    specify { expect(materialized_view).to respond_to :refresh_view! }

    context 'refreshing the view' do
      let(:build_with_data) { true }

      context 'after a change to the dependent table' do
        context 'without calling refresh_view!' do
          specify 'the count remains unchanged' do
            expect { create_two_things! }.to_not change { materialized_view.count }
          end
        end

        context 'when refresh_view! is called' do
          specify 'the count is updated' do
            expect do
              create_two_things!
              materialized_view.refresh_view!
            end.to change { materialized_view.count }.by 1
          end
        end
      end
    end

    context 'querying after creation' do
      context 'when the view has not been prepopulated' do
        specify do
          expect do
            materialized_view.count
          end.to raise_error ActiveRecord::StatementInvalid
        end

        context 'when refreshed' do
          before(:each) { materialized_view.refresh_view! }

          specify do
            expect do
              materialized_view.count
            end.to_not raise_error
          end
        end
      end

      context 'when created WITH DATA' do
        let(:build_with_data) { true }

        specify do
          expect do
            materialized_view.count
          end.to_not raise_error
        end
      end
    end
  end
end

RSpec.shared_examples_for 'adapters that do not support materialized views', materialized: false do
  context 'materialized views', test_materialized_view: true do
    subject { -> { build_test_materialized_view } }

    specify 'are not supported' do
      is_expected.to raise_error ActiveRecord::View::MaterializedViewNotSupported
    end
  end
end
