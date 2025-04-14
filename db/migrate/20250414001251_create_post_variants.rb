class CreatePostVariants < ActiveRecord::Migration[8.0]
  def change
    create_table :post_variants do |t|
      t.references :post, null: false, foreign_key: true
      t.references :locale, null: false, foreign_key: true
      t.text :title
      t.text :content

      t.timestamps
    end
  end
end
