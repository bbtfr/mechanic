class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string  :name
      t.integer :province_id
      t.index   :province_id
      t.integer :lbs_id
      t.index   :lbs_id
    end
  end
end
