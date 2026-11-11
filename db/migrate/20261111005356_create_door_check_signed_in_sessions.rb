class CreateDoorCheckSignedInSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :door_check_signed_in_sessions do |t|
      t.references :person, polymorphic: true, null: false
      t.datetime :signed_out_at

      t.timestamps
    end
  end
end
