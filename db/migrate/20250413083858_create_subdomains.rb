class CreateSubdomains < ActiveRecord::Migration[8.0]
  def change
    create_table :subdomains do |t|
      t.string :value, index: { unique: true }
      t.references :locale, null: false, foreign_key: true
      t.timestamps
    end
  end
end
