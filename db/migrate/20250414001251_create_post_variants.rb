class CreatePostVariants < ActiveRecord::Migration[8.0]
  def change
    create_table :post_variants do |t|
      t.references :post_id, null: false, foreign_key: true
      t.references :locale_id, null: false, foreign_key: true
      t.text :title
      t.text :content

      t.timestamps
    end
  end
end
