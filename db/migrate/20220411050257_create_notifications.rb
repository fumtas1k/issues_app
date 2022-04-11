class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.references :subject, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true
      t.text :message, null: false
      t.text :link_path, null: false
      t.boolean :read, null: false, default: false

      t.timestamps
    end
  end
end
