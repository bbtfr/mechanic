class AddUserWeixinOpenidToMechanics < ActiveRecord::Migration
  def change
    change_table :mechanics do |t|
      t.string :user_weixin_openid
    end
  end
end
