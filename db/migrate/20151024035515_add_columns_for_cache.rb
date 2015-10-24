class AddColumnsForCache < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.decimal :total_cost, precision: 10, scale: 2, default: 0
      t.integer :available_orders_count, default: 0
    end
    change_table :user_groups do |t|
      t.decimal :total_commission, precision: 10, scale: 2, default: 0
      t.integer :settled_orders_count, default: 0
      t.integer :users_count, default: 0
    end
    change_table :mechanics do |t|
      t.float :professionality_average, default: 4
      t.float :timeliness_average, default: 4
      t.decimal :total_income, precision: 10, scale: 2, default: 0
      t.integer :available_orders_count, default: 0
    end
  end
end
