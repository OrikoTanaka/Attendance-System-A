class AddColumnsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :employee_nunmber, :integer
    add_column :users, :uid, :string
    add_column :users, :basic_work_time, :datetime, default: Time.current.change(hour: 8, min: 0, sec: 0)
    add_column :users, :designated_work_start_time, :datetime
    add_column :users, :designated_work_end_time, :datetime
    add_column :users, :superior,  :boolean, default: false
  end
end
