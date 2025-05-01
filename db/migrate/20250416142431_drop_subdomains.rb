class DropSubdomains < ActiveRecord::Migration[8.0]
  def up
    drop_table :subdomains
  end

  def down
    create_table :subdomains do |t|
      t.string :value, index: { unique: true }
      t.references :locale, null: false, foreign_key: true
      t.timestamps
    end
  end
end
