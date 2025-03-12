class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string "ancestry", collation: "BINARY", null: false
      t.index "ancestry"
      # t.references :parent, foreign_key: { to_table: "categories" }
    end
  end
end
