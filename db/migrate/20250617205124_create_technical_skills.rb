class CreateTechnicalSkills < ActiveRecord::Migration[8.0]
  def change
    create_table :technical_skills do |t|
      t.string :name, null: false
      t.timestamps
    end
  end
end
