class AddOvertimeInfo2ToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_request_status, :string
  end
end
