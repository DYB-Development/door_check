class CreateDoorCheckProofs < ActiveRecord::Migration[8.1]
  def change
    create_table :door_check_proofs do |t|
      t.references :signed_in_session, null: false, foreign_key: { to_table: :door_check_signed_in_sessions }
      t.string :method_name, null: false
      t.datetime :proved_at, null: false

      t.timestamps
    end
  end
end
