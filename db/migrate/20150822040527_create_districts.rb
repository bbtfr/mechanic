class CreateDistricts < ActiveRecord::Migration
  def change
    create_table :districts do |t|
      t.string  :name
      t.integer :city_id
      t.index   :city_id
      t.integer :lbs_id
      t.index   :lbs_id
    end
  end
end
