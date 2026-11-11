class CreateDoorCheckCredentials < ActiveRecord::Migration[8.1]
  def change
    create_table :door_check_credentials do |t|
      t.references :person, polymorphic: true, null: false
      t.string :method_name, null: false
      t.text :secret
      t.datetime :last_used_at

      t.timestamps
    end
  end
end
