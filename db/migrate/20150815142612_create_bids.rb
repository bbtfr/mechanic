class CreateBids < ActiveRecord::Migration
  def change
    create_table :bids do |t|
      t.integer   :mechanic_id
      t.index     :mechanic_id
      t.integer   :order_id
      t.index     :order_id
      t.integer   :markup_price

      t.timestamps null: false
    end
  end
end
