class CreateResumes < ActiveRecord::Migration[8.0]
  def change
    create_table :resumes do |t|
      t.string :title, null: false
      t.string :name, null: false
      t.string :email_address, null: false
      t.string :phone_number
      t.string :position
      t.string :city
      t.text :summary
      t.date :birth_date
      t.integer :height
      t.integer :weight
      t.timestamps
    end
  end
end
