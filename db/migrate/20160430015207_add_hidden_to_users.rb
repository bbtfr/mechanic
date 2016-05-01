class AddHiddenToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :hidden, default: false
    end
  end
end
