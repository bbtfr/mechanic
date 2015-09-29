class AddTradeNoToOrders < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.string :trade_no
    end
  end
end
