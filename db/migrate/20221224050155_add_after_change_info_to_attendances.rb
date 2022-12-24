class AddAfterChangeInfoToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :started_at_after_change, :datetime
    add_column :attendances, :finished_at_after_change, :datetime
    add_column :attendances, :attendance_change_confirmer, :string
    add_column :attendances, :attendance_change_approval, :boolean
    add_column :attendances, :attendance_change_request_status, :string
  end
end
