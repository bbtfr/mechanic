class AddRemarkToFellowships < ActiveRecord::Migration
  def change
    change_table :fellowships do |t|
      t.text :remark
    end
  end
end
