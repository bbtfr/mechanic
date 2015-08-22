class CreateMechanics < ActiveRecord::Migration
  def change
    create_table :mechanics do |t|
      t.integer :province_id
      t.index   :province_id
      t.integer :city_id
      t.index   :city_id
      t.integer :district_id
      t.index   :district_id

      t.text    :description

      t.timestamps null: false
    end

    create_join_table :mechanics, :skills
  end
end
