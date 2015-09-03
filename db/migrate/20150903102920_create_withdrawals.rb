class CreateWithdrawals < ActiveRecord::Migration
  def change
    create_table :withdrawals do |t|
      t.integer :user_id
      t.index   :user_id

      t.integer :amount

      t.integer   :state_cd, default: 0
      t.index     :state_cd

      t.timestamps null: false
    end
  end
end
