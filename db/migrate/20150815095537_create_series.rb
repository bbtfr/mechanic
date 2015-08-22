class CreateSeries < ActiveRecord::Migration
  def change
    create_table :series do |t|
      t.string  :name
      t.integer :brand_id
      t.index   :brand_id
    end
  end
end
