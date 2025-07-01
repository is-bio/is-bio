class CreateLanguages < ActiveRecord::Migration[8.0]
  def change
    create_table :languages do |t|
      t.references :resume, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :proficiency
      t.timestamps
    end
  end
end
