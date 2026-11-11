class CreateDoorCheckChallenges < ActiveRecord::Migration[8.1]
  def change
    create_table :door_check_challenges do |t|
      t.references :person, polymorphic: true, null: false
      t.string :code_digest, null: false
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :used_at

      t.timestamps
    end
    add_index :door_check_challenges, :token_digest, unique: true
  end
end
