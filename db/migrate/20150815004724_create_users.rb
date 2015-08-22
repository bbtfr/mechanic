class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string     :mobile
      t.index      :mobile, unique: true

      # Authlogic::ActsAsAuthentic::PersistenceToken
      t.string     :persistence_token

      # Authlogic::ActsAsAuthentic::VerificationCode
      t.string     :verification_code

      # # Authlogic::Session::MagicColumns
      # t.integer    :login_count, default: 0, null: false
      # t.integer    :failed_login_count, default: 0, null: false
      # t.datetime   :last_request_at
      # t.datetime   :current_login_at
      # t.datetime   :last_login_at
      # t.string     :current_login_ip
      # t.string     :last_login_ip

      t.string     :weixin_openid

      t.boolean    :mobile_confirmed, default: false
      t.string     :nickname
      t.integer    :gender_cd
      t.string     :address

      t.integer    :balance

      t.attachment :avatar

      t.boolean    :is_mechanic
      t.integer    :mechanic_id
      t.index      :mechanic_id

      t.integer    :user_group_id
      t.index      :user_group_id

      t.timestamps null: false
    end
  end
end
