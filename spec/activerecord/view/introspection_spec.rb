describe ActiveRecord::View::Introspection do
  context 'with an unsupported database' do
    let(:fake_connection) { double("Fake Connection", adapter_name: 'unsupported') }

    specify do
      expect do
        ActiveRecord::View.introspector_for fake_connection
      end.to raise_error ActiveRecord::View::UnsupportedDatabase
    end
  end
end
