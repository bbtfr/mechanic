class CreateFellowships < ActiveRecord::Migration
  def change
    create_table :fellowships do |t|
      t.integer :mechanic_id
      t.index   :mechanic_id
      t.integer :user_id
      t.index   :user_id

      t.timestamps null: false
    end
  end
end
