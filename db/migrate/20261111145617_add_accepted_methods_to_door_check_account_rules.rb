class AddAcceptedMethodsToDoorCheckAccountRules < ActiveRecord::Migration[8.1]
  def change
    add_column :door_check_account_rules, :accepted_methods, :json
  end
end
