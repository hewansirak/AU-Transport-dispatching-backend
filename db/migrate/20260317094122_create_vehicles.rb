class CreateVehicles < ActiveRecord::Migration[7.2]
  def change
    create_table :vehicles do |t|
      t.string  :plate_number,  null: false
      t.string  :make,          null: false
      t.string  :model,         null: false
      t.integer :year
      t.integer :vehicle_type,  null: false, default: 0
      t.integer :capacity
      t.integer :status,        null: false, default: 0
      t.text    :notes
      t.timestamps
    end
    add_index :vehicles, :plate_number, unique: true
  end
end
