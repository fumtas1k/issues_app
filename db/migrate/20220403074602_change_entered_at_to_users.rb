class ChangeEnteredAtToUsers < ActiveRecord::Migration[6.0]
  def up
    change_column :users, :entered_at, :date, null: false
  end

  def down
    change_column :users, :entered_at, :datetime, null: false
  end
end
