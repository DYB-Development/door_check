class CreateDoorCheckTrustedDevices < ActiveRecord::Migration[8.1]
  def change
    create_table :door_check_trusted_devices do |t|
      t.references :person, polymorphic: true, null: false
      t.string :token_digest, null: false
      t.string :device
      t.datetime :expires_at, null: false
      t.datetime :last_used_at

      t.timestamps
    end
    add_index :door_check_trusted_devices, :token_digest, unique: true
  end
end
