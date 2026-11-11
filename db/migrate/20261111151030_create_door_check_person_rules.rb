class CreateDoorCheckPersonRules < ActiveRecord::Migration[8.1]
  def change
    create_table :door_check_person_rules do |t|
      t.references :person, polymorphic: true, null: false, index: { unique: true }
      t.boolean :second_step_required, null: false, default: false

      t.timestamps
    end
  end
end
