class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts, id: :string do |t|
      t.references :category, null: false, foreign_key: true
      t.string :permalink, null: false
      t.string :title, null: false
      t.text :content
      t.datetime :published_at, null: false
      t.datetime :updated_at
    end
  end
end
