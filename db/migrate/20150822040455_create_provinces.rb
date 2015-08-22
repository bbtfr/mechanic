class CreateProvinces < ActiveRecord::Migration
  def change
    create_table :provinces do |t|
      t.string  :name
      t.integer :lbs_id
      t.index   :lbs_id
    end
  end
end
