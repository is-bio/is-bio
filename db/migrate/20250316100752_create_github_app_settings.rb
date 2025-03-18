class CreateGithubAppSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :github_app_settings do |t|
      t.string :key, null: false
      t.string :value
      t.datetime :updated_at
    end

    add_index :github_app_settings, :key, unique: true
  end
end
