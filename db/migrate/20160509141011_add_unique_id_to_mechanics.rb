class AddUniqueIdToMechanics < ActiveRecord::Migration
  def change
    change_table :mechanics do |t|
      t.string :unique_id
    end
  end
end
