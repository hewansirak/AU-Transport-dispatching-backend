class CreateTripStatusUpdates < ActiveRecord::Migration[7.2]
  def change
    create_table :trip_status_updates do |t|
      t.references :transport_request, null: false, foreign_key: true
      t.references :driver,            null: false, foreign_key: true
      t.integer    :status,            null: false
      t.text       :note
      t.string     :location_note
      t.datetime   :reported_at,       null: false
      t.timestamps
    end
  end
end
