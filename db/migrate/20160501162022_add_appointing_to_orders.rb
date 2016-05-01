class AddAppointingToOrders < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.boolean :appointing, default: false
    end
  end
end
