class CreateDoorCheckEmailConfirmations < ActiveRecord::Migration[8.1]
  def change
    create_table :door_check_email_confirmations do |t|
      t.references :person, polymorphic: true, null: false, index: { unique: true }
      t.string :email
      t.datetime :confirmed_at

      t.timestamps
    end
  end
end
