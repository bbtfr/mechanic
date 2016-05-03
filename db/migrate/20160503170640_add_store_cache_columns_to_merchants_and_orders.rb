class AddStoreCacheColumnsToMerchantsAndOrders < ActiveRecord::Migration
  def change
    change_table :merchants do |t|
      t.rename :user_nickname, :store_nickname
      t.rename :user_mobile, :store_mobile
      t.rename :user_address, :store_address
    end

    change_table :orders do |t|
      t.string :store_nickname
    end
  end
end
