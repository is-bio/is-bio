class CreateProfessionalSkills < ActiveRecord::Migration[8.0]
  def change
    create_table :professional_skills do |t|
      t.string :name, null: false
      t.timestamps
    end
  end
end
