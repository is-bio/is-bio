class AddThumbnailToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :thumbnail, :string
  end
end
