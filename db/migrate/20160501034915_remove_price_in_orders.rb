class RemovePriceInOrders < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.remove  :price
      t.integer :procedure_price, default: 0
      t.change :markup_price, :integer, default: 0
    end
  end
end
