class AddMagicColumnsToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      # Authlogic::Session::MagicColumns
      t.integer    :login_count, default: 0, null: false
      t.integer    :failed_login_count, default: 0, null: false
      t.datetime   :last_request_at
      t.datetime   :current_login_at
      t.datetime   :last_login_at
      t.string     :current_login_ip
      t.string     :last_login_ip
    end

    change_table :merchants do |t|
      # Authlogic::Session::MagicColumns
      t.integer    :login_count, default: 0, null: false
      t.integer    :failed_login_count, default: 0, null: false
      t.datetime   :last_request_at
      t.datetime   :current_login_at
      t.datetime   :last_login_at
      t.string     :current_login_ip
      t.string     :last_login_ip
    end
  end
end
