class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string  :first_name,           null: false
      t.string  :last_name,            null: false
      t.string  :email,                null: false
      t.string  :password_digest,      null: false
      t.string  :telephone_extension
      t.integer :role,                 null: false, default: 0
      t.references :department,        null: true,  foreign_key: true
      t.boolean :active,               null: false, default: true
      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
