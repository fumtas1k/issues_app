class CreateStocks < ActiveRecord::Migration[6.0]
  def change
    create_table :stocks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :issue, null: false, foreign_key: true

      t.timestamps
    end
    add_index :stocks, %i[user_id issue_id], unique: true
  end
end
