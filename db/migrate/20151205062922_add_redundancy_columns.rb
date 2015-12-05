class AddRedundancyColumns < ActiveRecord::Migration
  def change
    change_table :mechanics do |t|
      t.string :user_nickname
      t.string :user_mobile
      t.string :user_address
    end

    change_table :merchants do |t|
      t.string :user_nickname
      t.string :user_mobile
      t.string :user_address
    end

    change_table :orders do |t|
      t.string :user_nickname
      t.string :user_mobile
      t.string :mechanic_nickname
      t.string :mechanic_mobile
      t.string :merchant_nickname
      t.string :merchant_mobile
    end
  end
end
