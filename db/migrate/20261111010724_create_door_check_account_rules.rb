class CreateDoorCheckAccountRules < ActiveRecord::Migration[8.1]
  def change
    create_table :door_check_account_rules do |t|
      t.references :account, polymorphic: true, null: false, index: { unique: true }
      t.boolean :second_step_required, null: false, default: false

      t.timestamps
    end
  end
end
