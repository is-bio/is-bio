class CreateSocialMediaAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :social_media_accounts do |t|
      t.string :key, null: false
      t.string :value
      t.datetime :updated_at
    end

    add_index :social_media_accounts, :key, unique: true
  end
end
