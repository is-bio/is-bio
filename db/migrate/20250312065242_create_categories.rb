class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false

      # PostgreSQL
      # t.string "ancestry", collation: 'C', null: false
      # MySQL
      # t.string "ancestry", collation: 'utf8mb4_bin', null: false
      # SQLite
      t.string "ancestry", collation: "BINARY", null: false

      t.index "ancestry"
    end
  end
end
