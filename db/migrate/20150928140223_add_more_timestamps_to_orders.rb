class AddMoreTimestampsToOrders < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.datetime :paid_at
      t.datetime :refunded_at
    end
  end
end
