class AddAuthenticatorToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :authenticator_code, :string
    add_column :users, :backup_codes, :string
  end
end
