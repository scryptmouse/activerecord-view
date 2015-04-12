describe ActiveRecord::Migration::CommandRecorder do
  let(:recorder) { described_class.new }

  let(:sample_view_name) { :foo }
  let(:sample_view_body) { 'SELECT 1' }
  let(:sample_view_options) { { force: true } }
  let(:sample_view_proc) { nil }

  def test_inversion!(method)
    recorder.revert do
      recorder.__send__(method, *sample_view_args, &sample_view_proc)
    end
  end

  context 'inversions' do
    described_class::CREATE_VIEW_METHODS.each do |method_name|
      inverse_method = described_class::VIEW_METHOD_PAIRS.fetch method_name

      describe "#invert_#{method_name}" do
        let(:sample_view_args) { [sample_view_name, sample_view_body, sample_view_options] }

        subject { recorder.commands.first }

        it 'inverts the command' do
          test_inversion! method_name

          is_expected.to match_array [inverse_method, [sample_view_name]]
        end
      end
    end

    described_class::DROP_VIEW_METHODS.each do |method_name|
      inverse_method = described_class::VIEW_METHOD_PAIRS.fetch method_name

      describe "#invert_#{method_name}" do
        context 'without a view body' do
          let(:sample_view_args) { [sample_view_name] }

          it 'explodes' do
            expect do
              test_inversion! method_name
            end.to raise_error ActiveRecord::IrreversibleMigration
          end
        end

        context 'with a view body' do
          subject { recorder.commands.first }

          let(:expected_inversion) do
            [inverse_method, sample_view_args, sample_view_proc]
          end

          before(:each) do
            test_inversion! method_name
          end

          context 'as a proc' do
            let!(:sample_view_proc) { proc { sample_view_body } }
            let!(:sample_view_args) { [sample_view_name, sample_view_options] }

            it 'inverts the drop' do
              is_expected.to match_array expected_inversion
            end
          end

          context 'as a param' do
            let(:sample_view_args) { [sample_view_name, sample_view_body, sample_view_options] }

            it 'inverts the drop' do
              is_expected.to match_array expected_inversion
            end
          end
        end
      end
    end
  end
end
