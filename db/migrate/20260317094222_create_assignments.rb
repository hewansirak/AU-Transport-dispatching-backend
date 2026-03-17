class CreateAssignments < ActiveRecord::Migration[7.2]
  def change
    create_table :assignments do |t|
      t.references :transport_request, null: false, foreign_key: true
      t.references :driver,            null: false, foreign_key: true
      t.references :vehicle,           null: false, foreign_key: true
      t.references :dispatcher,        null: false, foreign_key: { to_table: :users }
      t.text       :notes
      t.timestamps
    end
  end
end
