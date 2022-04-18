class AddFavoritesCountToIssues < ActiveRecord::Migration[6.0]
  def change
    add_column :issues, :favorites_count, :integer, null: false, default: 0
  end
end
