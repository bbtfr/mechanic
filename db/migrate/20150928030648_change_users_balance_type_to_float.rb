class ChangeUsersBalanceTypeToFloat < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.change    :balance, :float, default: 0.0
    end
  end
end
