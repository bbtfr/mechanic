class AddHotlineToStores < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :hotline
    end
    change_table :merchants do |t|
      t.string :store_hotline
    end
    change_table :orders do |t|
      t.string :store_hotline
    end
  end
end
