class AddEmailAndPurposeToDoorCheckChallenges < ActiveRecord::Migration[8.1]
  def change
    add_column :door_check_challenges, :email, :string
    add_column :door_check_challenges, :purpose, :string, null: false, default: "sign_in"
  end
end
