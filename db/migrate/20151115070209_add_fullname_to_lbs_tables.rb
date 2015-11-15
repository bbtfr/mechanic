class AddFullnameToLbsTables < ActiveRecord::Migration
  def change
    change_table :provinces do |t|
      t.string :fullname
      t.index  :fullname
    end

    change_table :cities do |t|
      t.string :fullname
      t.index  :fullname
    end

    change_table :districts do |t|
      t.string :fullname
      t.index  :fullname
    end
  end
end
