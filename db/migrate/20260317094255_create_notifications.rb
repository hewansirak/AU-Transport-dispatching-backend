class CreateNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :notifications do |t|
      t.references :transport_request, null: false, foreign_key: true
      t.references :recipient,         null: false, foreign_key: { to_table: :users }
      t.integer    :channel,           null: false, default: 0
      t.integer    :notification_type, null: false
      t.datetime   :sent_at
      t.integer    :status,            null: false, default: 0
      t.jsonb      :metadata,          default: {}
      t.timestamps
    end
  end
end
