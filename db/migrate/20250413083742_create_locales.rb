class CreateLocales < ActiveRecord::Migration[7.1]
  def change
    create_table :locales, id: false do |t|
      t.string :id, primary_key: true, null: false
      t.string :english_name, null: false
      t.string :name, null: false
      t.timestamps
    end

    add_index :locales, :english_name, unique: true
    add_index :locales, :name, unique: true
  end
end
