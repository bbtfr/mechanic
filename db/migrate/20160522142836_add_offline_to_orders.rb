class AddOfflineToOrders < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.boolean :offline
    end
  end
end
