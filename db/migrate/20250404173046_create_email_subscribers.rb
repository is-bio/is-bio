class CreateEmailSubscribers < ActiveRecord::Migration[8.0]
  def change
    create_table :email_subscribers do |t|
      t.string :email, null: false
      t.boolean :confirmed, default: false
      t.string :token

      t.timestamps
    end

    add_index :email_subscribers, :email, unique: true
  end
end
