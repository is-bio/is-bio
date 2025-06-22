class CreateEducations < ActiveRecord::Migration[8.0]
  def change
    create_table :educations do |t|
      t.string :school_name, null: false
      t.string :degree
      t.string :field_of_study
      t.integer :start_year
      t.integer :end_year
      t.timestamps
    end
  end
end
