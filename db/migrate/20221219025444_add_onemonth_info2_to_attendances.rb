class AddOnemonthInfo2ToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :onemonth_approval, :boolean
  end
end
