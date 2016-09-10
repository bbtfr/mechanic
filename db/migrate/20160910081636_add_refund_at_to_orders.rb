class AddRefundAtToOrders < ActiveRecord::Migration[5.0]
  def change
    change_table :orders do |t|
      t.datetime :refund_at
    end
  end
end
