class CreateMerchants < ActiveRecord::Migration
  def change
    create_table :merchants do |t|
      t.integer    :user_id
      t.index      :user_id

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
      # t.boolean    :active, default: false
      # t.boolean    :approved, default: false
      t.boolean    :confirmed, default: false

      t.string     :nickname

      t.attachment :avatar

      t.integer    :role_cd, default: 0
      t.index      :role_cd

      t.timestamps null: false
    end
  end
end
