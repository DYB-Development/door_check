class AddDeviceToDoorCheckSignedInSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :door_check_signed_in_sessions, :device, :string
    add_column :door_check_signed_in_sessions, :ip_address, :string
    add_column :door_check_signed_in_sessions, :last_used_at, :datetime
  end
end
