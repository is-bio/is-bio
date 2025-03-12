class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.references :category, null: false, foreign_key: true
      t.integer :key, null: false
      t.string :permalink, null: false
      t.string :title, null: false
      t.string :content, null: false

      t.timestamps
    end

    add_index :posts, :key, unique: true
  end
end
