class AddPaidAtToWithdrawals < ActiveRecord::Migration
  def change
    change_table :withdrawals do |t|
      t.datetime :paid_at
    end
  end
end
