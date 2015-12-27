class AddClosedAtToOrders < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.datetime :closed_at
    end
  end
end
