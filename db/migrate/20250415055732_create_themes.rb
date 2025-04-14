class CreateThemes < ActiveRecord::Migration[8.0]
  def change
    create_table :themes do |t|
      t.string :name, null: false
      t.boolean :enabled, null: false, default: true
      t.boolean :free, null: false, default: true
      t.integer :color, null: false, default: 0
    end
  end
end
