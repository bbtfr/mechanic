class AddRevokeOrdersCountToMechanics < ActiveRecord::Migration
  def change
    change_table :mechanics do |t|
      t.integer :revoke_orders_count
    end
  end
end
