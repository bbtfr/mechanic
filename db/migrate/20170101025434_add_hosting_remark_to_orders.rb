class AddHostingRemarkToOrders < ActiveRecord::Migration[5.0]
  def change
    change_table :orders do |t|
      t.text :hosting_remark
    end
  end
end
