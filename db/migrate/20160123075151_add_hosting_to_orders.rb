class AddHostingToOrders < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.boolean :hosting, default: false
      t.index   :hosting
    end

    change_table :users do |t|
      t.boolean :host, default: false
      t.index   :host
    end
  end
end
