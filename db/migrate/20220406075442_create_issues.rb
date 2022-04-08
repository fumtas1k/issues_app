class CreateIssues < ActiveRecord::Migration[6.0]
  def change
    create_table :issues do |t|
      t.string :title, null: false, limit: 30
      t.integer :status, null: false, limit: 1, default: 0
      t.integer :scope, null: false, limit: 1, default: 0
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
