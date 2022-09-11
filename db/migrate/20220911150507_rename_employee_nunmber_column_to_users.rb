class RenameEmployeeNunmberColumnToUsers < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :employee_nunmber, :employee_number
  end
end
