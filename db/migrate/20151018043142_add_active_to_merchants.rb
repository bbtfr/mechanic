class AddActiveToMerchants < ActiveRecord::Migration
  def change
    change_table :merchants do |t|
      t.boolean   :active, default: true
    end
  end
end
