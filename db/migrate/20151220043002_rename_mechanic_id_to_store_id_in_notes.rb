class RenameMechanicIdToStoreIdInNotes < ActiveRecord::Migration
  def change
    change_table :notes do |t|
      t.rename :merchant_id, :store_id
    end
  end
end
