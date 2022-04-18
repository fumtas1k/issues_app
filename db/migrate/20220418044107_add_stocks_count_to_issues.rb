class AddStocksCountToIssues < ActiveRecord::Migration[6.0]
  def change
    add_column :issues, :stocks_count, :integer, null: false, default: 0
  end
end
