class AddLocationToUsersAndOrders < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.float :lat
      t.float :lng
    end

    change_table :orders do |t|
      t.float :lat
      t.float :lng
    end
  end
end
