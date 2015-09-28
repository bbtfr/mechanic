class AddMarkupPriceToOrders < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.integer   :markup_price, default: 0
    end
  end
end
