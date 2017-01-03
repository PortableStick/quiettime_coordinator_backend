class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :password_digest
      t.string :plans, array: true, default: '{}'
      t.string :password_reset_token
      t.boolean :confirmed, default: false
      t.index :password_reset_token
      t.index :email

      t.timestamps
    end
  end
end
