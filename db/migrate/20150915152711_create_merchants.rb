class CreateMerchants < ActiveRecord::Migration
  def change
    create_table :merchants do |t|
      t.integer    :user_id
      t.index      :user_id

      t.string     :mobile
      t.index      :mobile, unique: true

      t.boolean    :mobile_confirmed, default: false
      t.string     :nickname

      t.attachment :avatar

      t.integer    :role_cd, default: 0
      t.index      :role_cd

      t.timestamps null: false
    end
  end
end
