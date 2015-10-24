class AddRefundCdToOrders < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.integer :refund_cd, default: 0
      t.index   :refund_cd
    end
  end
end
