class AddOnemonthInfoToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :onemonth_request_status, :string
    add_column :attendances, :onemonth_confirmer, :string
  end
end
