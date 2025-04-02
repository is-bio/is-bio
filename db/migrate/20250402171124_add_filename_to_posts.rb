class AddFilenameToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :filename, :text
  end
end
