class AddProvinceCdAndCityCdToOrders < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.integer :province_cd
      t.integer :city_cd
    end
  end
end
