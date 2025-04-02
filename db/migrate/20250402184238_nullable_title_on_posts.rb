class NullableTitleOnPosts < ActiveRecord::Migration[8.0]
  def change
    change_column :posts, :title, :text, null: true
  end
end
