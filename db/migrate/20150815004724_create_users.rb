class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string    :mobile
      t.index     :mobile, unique: true

      # Authlogic::ActsAsAuthentic::PersistenceToken
      t.string    :persistence_token

      # Authlogic::ActsAsAuthentic::VerificationCode
      t.string    :verification_code

      # # Authlogic::Session::MagicColumns
      # t.integer   :login_count, default: 0, null: false
      # t.integer   :failed_login_count, default: 0, null: false
      # t.datetime  :last_request_at
      # t.datetime  :current_login_at
      # t.datetime  :last_login_at
      # t.string    :current_login_ip
      # t.string    :last_login_ip

      t.boolean   :mobile_confirmed, default: false
      t.string    :nickname
      t.integer   :gender_cd
      t.string    :address

      t.boolean   :is_mechanic

      t.timestamps null: false
    end

    User.create(mobile: "15901013540", verification_code: "000000")
  end
end
