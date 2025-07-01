class CreateExperiences < ActiveRecord::Migration[8.0]
  def change
    create_table :experiences do |t|
      t.references :resume, null: false, foreign_key: true
      t.string :company_name, null: false
      t.string :title, null: false
      t.text :description
      t.integer :start_year
      t.integer :start_month
      t.integer :end_year
      t.integer :end_month
      t.timestamps
    end
  end
end
