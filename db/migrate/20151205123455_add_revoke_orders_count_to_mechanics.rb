class AddRevokeOrdersCountToMechanics < ActiveRecord::Migration
  def change
    change_table :mechanics do |t|
      t.integer :revoke_orders_count, default: 0
    end
  end
end
