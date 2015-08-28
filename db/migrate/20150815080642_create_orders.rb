class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer   :user_id
      t.integer   :mechanic_id
      t.string    :address
      t.datetime  :appointment
      t.integer   :skill_id
      t.integer   :brand_id
      t.integer   :series_id
      t.integer   :quoted_price
      t.integer   :price
      t.text      :remark

      t.integer   :professionality
      t.integer   :timeliness
      t.text      :review

      t.integer   :state_cd, default: 0
      t.index     :state_cd

      t.integer   :mechanic_sent_count, default: 0

      t.timestamps null: false
    end
  end
end
