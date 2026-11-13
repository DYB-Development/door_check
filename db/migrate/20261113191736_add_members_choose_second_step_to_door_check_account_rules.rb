class AddMembersChooseSecondStepToDoorCheckAccountRules < ActiveRecord::Migration[8.1]
  def change
    add_column :door_check_account_rules, :members_choose_second_step, :boolean, default: true, null: false
  end
end
