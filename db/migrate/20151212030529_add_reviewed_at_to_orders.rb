class AddReviewedAtToOrders < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.datetime :reviewed_at
      t.datetime :finish_working_at
    end
  end
end
