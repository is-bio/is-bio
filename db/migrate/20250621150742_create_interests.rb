class CreateInterests < ActiveRecord::Migration[8.0]
  def change
    create_table :interests do |t|
      t.references :resume, null: false, foreign_key: true
      t.string :name, null: false
      t.timestamps
    end
  end
end
