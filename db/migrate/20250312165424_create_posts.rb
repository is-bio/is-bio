class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :id2, index: { unique: true }
      t.references :category, null: false, foreign_key: true
      t.string :permalink, null: false
      t.string :title, null: false
      t.text :content
      t.datetime :published_at, null: false
      t.datetime :updated_at
    end
  end
end
