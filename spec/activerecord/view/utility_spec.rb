describe ActiveRecord::View::Utility do
  describe 'cleanup' do
    context 'with messy text' do
      subject { described_class.cleanup "  foo\n  bar  \t  " }

      it 'cleans up the text' do
        is_expected.to eq 'foo bar'
      end
    end

    context 'with text that contains multiple spaces' do
      subject { described_class.cleanup " foo  bar " }

      it 'leaves the internal whitespace intact' do
        is_expected.to eq 'foo  bar'
      end
    end
  end
end
