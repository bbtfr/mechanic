class CreateRecharges < ActiveRecord::Migration[5.0]
  def change
    create_table :recharges do |t|
      t.integer   :user_id
      t.index     :user_id

      t.integer   :store_id
      t.index     :store_id

      t.integer   :amount

      t.integer   :state_cd, default: 0
      t.index     :state_cd

      t.integer   :pay_type_cd, default: 0
      t.index     :pay_type_cd

      t.string    :trade_no

      t.datetime  :paid_at

      t.timestamps
    end
  end
end
