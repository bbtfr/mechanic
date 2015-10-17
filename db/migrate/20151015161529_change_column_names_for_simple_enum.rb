class ChangeColumnNamesForSimpleEnum < ActiveRecord::Migration
  def change
    change_table :mechanics do |t|
      t.rename :province_id, :province_cd
      t.rename :city_id, :city_cd
      t.rename :district_id, :district_cd
    end

    change_table :orders do |t|
      t.rename :skill_id, :skill_cd
      t.rename :brand_id, :brand_cd
      t.rename :series_id, :series_cd
    end
  end
end
