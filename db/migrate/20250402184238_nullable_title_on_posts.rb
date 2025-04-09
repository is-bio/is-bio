class NullableTitleOnPosts < ActiveRecord::Migration[8.0]
  def up
    change_column :posts, :title, :text, null: true
  end

  def down
    change_column :posts, :title, :text, null: false
  end
end
