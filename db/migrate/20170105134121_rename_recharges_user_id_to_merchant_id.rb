class RenameRechargesUserIdToMerchantId < ActiveRecord::Migration[5.0]
  def change
    change_table :recharges do |t|
      t.rename :user_id, :merchant_id
    end
  end
end
