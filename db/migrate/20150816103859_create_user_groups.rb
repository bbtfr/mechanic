class CreateUserGroups < ActiveRecord::Migration
  def change
    create_table :user_groups do |t|
      t.string    :nickname
      t.text      :description

      t.integer   :user_id
      t.index     :user_id

      t.timestamps null: false
    end
  end
end
