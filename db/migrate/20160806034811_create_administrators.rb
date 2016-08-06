class CreateAdministrators < ActiveRecord::Migration[5.0]
  def change
    create_table :administrators do |t|
      t.string     :mobile
      t.index      :mobile, unique: true

      # Authlogic::ActsAsAuthentic::Password
      t.string    :crypted_password
      t.string    :password_salt

      # Authlogic::ActsAsAuthentic::PersistenceToken
      t.string     :persistence_token

      # Authlogic::ActsAsAuthentic::VerificationCode
      t.string     :verification_code

      # # Authlogic::Session::MagicStates
      t.boolean    :active, default: true
      # t.boolean    :approved, default: false
      t.boolean    :confirmed, default: false

      # Authlogic::Session::MagicColumns
      t.integer    :login_count, default: 0, null: false
      t.integer    :failed_login_count, default: 0, null: false
      t.datetime   :last_request_at
      t.datetime   :current_login_at
      t.datetime   :last_login_at
      t.string     :current_login_ip
      t.string     :last_login_ip

      t.string     :nickname

      t.attachment :avatar

      t.integer    :role_cd, default: 0
      t.index      :role_cd

      t.timestamps null: false
    end
  end
end
