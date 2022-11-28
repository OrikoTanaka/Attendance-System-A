class AddOvertimeNoticeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :approval, :boolean
  end
end
