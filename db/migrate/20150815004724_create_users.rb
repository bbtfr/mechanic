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

      # # Authlogic::Session::MagicStates
      # t.boolean   :active, default: false
      # t.boolean   :approved, default: false
      t.boolean   :confirmed, default: false

      t.string     :weixin_openid

      t.string     :nickname
      t.integer    :gender_cd
      t.string     :address

      t.integer    :balance, default: 0

      t.attachment :avatar

      t.integer    :role_cd, default: 0
      t.index      :role_cd

      t.integer    :user_group_id
      t.index      :user_group_id

      t.timestamps null: false
    end
  end
end
