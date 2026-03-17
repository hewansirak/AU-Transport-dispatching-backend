class CreateTransportRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :transport_requests do |t|
      t.references :requester,          null: false, foreign_key: { to_table: :users }
      t.string     :originator_office,  null: false
      t.references :department,         null: false, foreign_key: true
      t.string     :telephone_extension
      t.date       :required_date,      null: false
      t.time       :required_from_time, null: false
      t.time       :required_to_time,   null: false
      t.boolean    :working_hours,      null: false, default: true
      t.string     :destination,        null: false
      t.text       :purpose,            null: false
      t.integer    :service_type,       null: false, default: 0
      t.integer    :passenger_count
      t.integer    :status,             null: false, default: 0
      t.references :reviewed_by,        null: true,  foreign_key: { to_table: :users }
      t.datetime   :reviewed_at
      t.text       :rejection_reason
      t.references :assigned_by,        null: true,  foreign_key: { to_table: :users }
      t.datetime   :assigned_at
      t.timestamps
    end
  end
end
