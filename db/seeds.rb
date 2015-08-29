# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create(mobile: "15901013540", verification_code: "000000",
  nickname: "Li", gender_cd: 1, address: "Addr.", mobile_confirmed: true)

%w(贴膜 安导航 等等).each do |skill|
  Skill.create(name: skill)
end

DistrictList = LBS.district_list["result"]

def create_province province
  record = Province.create(name: province["name"] || province["fullname"], lbs_id: province["id"])
  DistrictList[1][province["cidx"][0]..province["cidx"][1]].each do |city|
    create_city city, record.id
  end if province["cidx"]
end

def create_city city, province_id
  record = City.create(name: city["name"] || city["fullname"], province_id: province_id, lbs_id: city["id"])
  DistrictList[2][city["cidx"][0]..city["cidx"][1]].each do |district|
    create_district district, record.id
  end if city["cidx"]
end

def create_district district, city_id
  District.create(name: district["name"] || district["fullname"], city_id: city_id, lbs_id: district["id"])
end

ActiveRecord::Base.transaction do
  DistrictList[0].each do |province|
    create_province province
  end
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
