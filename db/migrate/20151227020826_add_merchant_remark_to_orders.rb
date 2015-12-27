class AddMerchantRemarkToOrders < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.text :merchant_remark
    end
  end
end
