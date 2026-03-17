class CreateDrivers < ActiveRecord::Migration[7.2]
  def change
    create_table :drivers do |t|
      t.references :user,           null: false, foreign_key: true
      t.string     :license_number, null: false
      t.date       :license_expiry
      t.string     :phone_number,   null: false
      t.integer    :status,         null: false, default: 0
      t.text       :notes
      t.timestamps
    end
    add_index :drivers, :license_number, unique: true
  end
end
