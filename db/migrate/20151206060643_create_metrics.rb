class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.integer :source_id
      t.string  :source_type
      t.integer :user_id

      t.string  :method
      t.text    :data

      t.timestamps
    end

    add_index :metrics, [:source_type, :source_id]
    add_index :metrics, :user_id
  end
end
