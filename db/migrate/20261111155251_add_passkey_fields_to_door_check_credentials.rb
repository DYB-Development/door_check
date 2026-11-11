class AddPasskeyFieldsToDoorCheckCredentials < ActiveRecord::Migration[8.1]
  def change
    add_column :door_check_credentials, :name, :string
    add_column :door_check_credentials, :external_id, :string
    add_index :door_check_credentials, :external_id, unique: true
    add_column :door_check_credentials, :public_key, :text
    add_column :door_check_credentials, :sign_count, :integer
  end
end
