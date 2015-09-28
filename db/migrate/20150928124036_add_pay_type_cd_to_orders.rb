class AddPayTypeCdToOrders < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.integer :pay_type_cd, default: 0
      t.index   :pay_type_cd
    end
  end
end
