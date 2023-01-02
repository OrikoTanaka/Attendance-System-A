class AddAttendanceInfoToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :started_at_first, :datetime
    add_column :attendances, :finished_at_first, :datetime
  end
end
