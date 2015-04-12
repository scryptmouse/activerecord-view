READONLY_METHODS = ActiveRecord::View::ReadOnly::READONLY_CLASS_METHODS

RSpec.shared_examples_for 'view specs' do
  context 'introspection' do
    context 'getting the view definition' do
      let(:should_raise_error) { false }

      let(:view_definition) { view.view_definition raise_error: should_raise_error }

      subject { -> { view_definition } }

      context 'for an undefined view' do
        context 'and raise_error is true' do
          let(:should_raise_error) { true }

          it { is_expected.to raise_error }
        end

        context 'and raise_error is false' do
          it { is_expected.to_not raise_error }

          it { expect(view_definition).to be_blank }
        end
      end

      context 'for an existing view' do
        include_context 'default view'

        it { expect(view_definition).to be_present }
      end

      context 'for a regular model' do
        subject { -> { model.view_definition } }

        it { is_expected.to raise_error NoMethodError }
      end

      context 'via ActiveRecord::View.definition_for' do
        include_context 'default view'

        def definition_for(model_or_name, connection: nil)
          ActiveRecord::View.definition_for model_or_name, connection: connection
        end

        let(:model_or_name) { }
        let(:definition_connection) { nil }

        let(:run_definition) { definition_for model_or_name, connection: definition_connection }

        context 'with an Arel::Table' do
          let(:model_or_name) { view.arel_table }

          specify do
            expect do
              run_definition
            end.to_not raise_error
          end

          specify do
            expect(run_definition).to be_present
          end
        end

        context 'with a string' do
          let(:model_or_name) { view.table_name }

          context 'with a connectible' do
            let(:definition_connection) { view.connection }

            specify { expect(run_definition).to be_present }
          end

          context 'without a connection' do
            specify do
              expect do
                run_definition
              end.to raise_error ActiveRecord::View::Error
            end
          end
        end

        context 'with a symbol' do
          let(:model_or_name) { view.table_name.to_sym }

          context 'with a connectible' do
            let(:definition_connection) { view.connection }

            specify { expect(run_definition).to be_present }
          end

          context 'without a connection' do
            specify do
              expect do
                run_definition
              end.to raise_error ActiveRecord::View::Error
            end
          end
        end

        context 'with something invalid' do
          let(:model_or_name) { nil }

          specify do
            expect do
              run_definition
            end.to raise_error ActiveRecord::View::Error
          end
        end
      end
    end
  end

  context 'view predicates' do
    context 'for a regular model' do
      subject { model }

      it { is_expected.to_not be_a_view }
      it { is_expected.to_not be_a_materialized_view }
    end

    context 'for a regular view' do
      subject { view }

      it { is_expected.to be_a_view }
      it { is_expected.to_not be_a_materialized_view }
    end

    context 'for a materialized view' do
      subject { materialized_view }

      it { is_expected.to be_a_view }
      it { is_expected.to be_a_materialized_view }
    end if metadata[:materialized]
  end

  context 'view classes' do
    include_context 'default view'

    context 'when the underlying table is updated' do
      specify 'have their counts updated appropriately' do
        expect do
          create_two_things!
        end.to change { model.count }.by(2) & change { view.count }.by(1)
      end
    end


    context 'on a relation' do
      let(:relation) { view.where(veracity: true) }

      READONLY_METHODS.each do |method|
        describe "##{method}", raises_readonly: true do
          subject { lambda { relation.__send__(method, some_value: true) } }
        end
      end
    end

    context 'at the class level' do
      READONLY_METHODS.each do |method|
        describe ".#{method}", raises_readonly: true do
          subject do
            lambda { view.__send__ method, some_value: true }
          end
        end
      end
    end

    context 'at the instance level' do
      let(:instance) { view.first }

      specify('are readonly') { expect(instance).to be_readonly }

      describe '#delete', raises_readonly: true do
        subject do
          lambda { instance.delete }
        end
      end

      describe '#destroy', raises_readonly: true do
        subject { -> { instance.destroy } }
      end

      describe '#save', raises_readonly: true do
        subject do
          lambda do
            instance.veracity = false
            instance.save
          end
        end
      end
    end
  end
end

RSpec.shared_examples_for 'raising a readonly record', raises_readonly: true do
  specify do
    is_expected.to raise_error ActiveRecord::ReadOnlyRecord
  end
end
