require 'spec_helper'

describe ActiveRecord::View do
  context 'using mysql', mysql: true, materialized: false do
    include_examples 'view specs'
  end

  context 'using postgres', pg: true, materialized: true do
    include_examples 'view specs'
  end

  context 'using sqlite3', sqlite3: true, materialized: false do
    include_examples 'view specs'
  end
end
