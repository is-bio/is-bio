class AddCategoryIdToPosts < ActiveRecord::Migration[8.0]
  def change
    add_reference :posts, :category, null: false, foreign_key: true, default: 2
  end
end
