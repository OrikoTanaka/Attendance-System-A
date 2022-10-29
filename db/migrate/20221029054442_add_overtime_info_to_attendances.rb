class AddOvertimeInfoToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :end_time, :time
    add_column :attendances, :overtime_reason, :string
    add_column :attendances, :nextday, :boolean, default: false
    add_column :attendances, :confirmer, :string
  end
end
