class AddApprovalToDoorCheckChallenges < ActiveRecord::Migration[8.1]
  def change
    add_column :door_check_challenges, :number, :string
    add_column :door_check_challenges, :device, :string
    add_column :door_check_challenges, :ip_address, :string
    add_column :door_check_challenges, :approved_at, :datetime
    add_column :door_check_challenges, :declined_at, :datetime
    change_column_null :door_check_challenges, :code_digest, true
    change_column_null :door_check_challenges, :token_digest, true
  end
end
