# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Skill.destroy_all
%w(贴膜 安导航 等等).each do |skill|
  Skill.create(name: skill)
end

ActiveRecord::Base.transaction do
  # Province.destroy_all
  # City.destroy_all
  # District.destroy_all

  ActiveRecord::Migration.rename_table :provinces, :provinces_bak
  ActiveRecord::Migration.rename_table :cities, :cities_bak
  ActiveRecord::Migration.rename_table :districts, :districts_bak

  ActiveRecord::Migration.create_table :provinces do |t|
    t.string  :name
    t.string  :fullname
    t.index   :fullname
    t.integer :lbs_id
    t.index   :lbs_id
  end
  ActiveRecord::Migration.create_table :cities do |t|
    t.string  :name
    t.string  :fullname
    t.index   :fullname
    t.integer :province_id
    t.index   :province_id
    t.integer :lbs_id
    t.index   :lbs_id
  end
  ActiveRecord::Migration.create_table :districts do |t|
    t.string  :name
    t.string  :fullname
    t.index   :fullname
    t.integer :city_id
    t.index   :city_id
    t.integer :lbs_id
    t.index   :lbs_id
  end
end

DistrictList = LBS.district_list["result"]
Municipalities = %w(北京 上海 天津 重庆 香港 澳门)

def create_province pd
  p = Province.create(name: pd["name"] || pd["fullname"], fullname: pd["fullname"], lbs_id: pd["id"])
  DistrictList[1][pd["cidx"][0]..pd["cidx"][1]].each do |cd|
    if Municipalities.include? pd["name"]
      c = City.where(name: pd["name"] || pd["fullname"], fullname: pd["fullname"], province_id: p.id, lbs_id: pd["id"]).first_or_create
      create_district cd, c
    else
      create_city cd, p
    end
  end
end

def create_city cd, p
  c = City.create(name: cd["name"] || cd["fullname"], fullname: cd["fullname"], province_id: p.id, lbs_id: cd["id"])
  if cd["cidx"]
    DistrictList[2][cd["cidx"][0]..cd["cidx"][1]].each do |dd|
      create_district dd, c
    end
  end
end

def create_district dd, c
  District.create(name: dd["name"] || dd["fullname"], fullname: dd["fullname"], city_id: c.id, lbs_id: dd["id"])
end

ActiveRecord::Base.transaction do
  DistrictList[0].each do |pd|
    create_province pd
  end
  nil
end

doc = Nokogiri::HTML open("http://www.ebaoyang.cn/basic/car/show_brand").read
doc.css(".choose_list a").each do |brand|
  ActiveRecord::Base.transaction do
    record = Brand.create(name: brand.text)
    doc = Nokogiri::HTML open("http://www.ebaoyang.cn/#{brand.attr("href")}").read
    doc.css(".choose_list a").each do |series|
      name = series.text.strip
      name = "#{$1.strip}（#{$2.strip.titlecase}）" if name =~ /(.*?)[\(（](.*?)[\)）]/
      Series.create(name: name, brand_id: record.id)
    end
  end
end
