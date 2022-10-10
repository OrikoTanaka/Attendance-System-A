class Base < ApplicationRecord
  validates :name, presence: true, length: { maximum: 10 }
  validates :attendance_type, presence: true, length: { maximum: 10 }
end
