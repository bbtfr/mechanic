class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer   :user_id
      t.integer   :mechanic_id
      t.string    :address
      t.datetime  :appointment
      t.integer   :order_type_id
      t.integer   :brand_id
      t.integer   :series_id
      t.integer   :quoted_price
      t.integer   :price
      t.text      :remark

      t.integer   :professionality
      t.integer   :timeliness
      t.text      :review

      t.timestamps null: false
    end
  end
end
