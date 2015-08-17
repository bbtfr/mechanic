class CreateOrderTypes < ActiveRecord::Migration
  def change
    create_table :order_types do |t|
      t.string :name
    end
  end
end
