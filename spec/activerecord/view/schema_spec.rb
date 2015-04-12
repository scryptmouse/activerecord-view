describe 'schema commands' do
  context 'using mysql', mysql: true do
    include_examples 'schema specs'
  end

  context 'using postgres', pg: true do
    include_examples 'schema specs'
  end

  context 'using sqlite3', sqlite3: true do
    include_examples 'schema specs'
  end
end
