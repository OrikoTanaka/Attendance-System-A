class Attendance < ApplicationRecord
  belongs_to :user

  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  validates :end_time, :overtime_reason, :confirmer, presence: true, on: :update_request_overtime
  

  # 出勤時間が存在しない場合、退勤時間は無効
  validate :finished_at_is_invalid_without_a_started_at
  
  # 出勤・退勤時間どちらも存在する時、出勤時間より早い退勤時間は無効
  validate :started_at_than_finished_at_fast_if_invalid

  # 出勤時間が存在、退勤時間が存在しない時、更新は無効
  validate :started_at_is_invalid_withiout_a_finished_at, on: :update_one_month # update_one_monthのアクション実行の時のみバリデーションをかける

  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end

  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at
    end
  end

  def started_at_is_invalid_withiout_a_finished_at
    errors.add(:finished_at, "が必要です") if started_at.present? && finished_at.blank?
  end

  # 残業終了時間と指定勤務終了時間を受け取り、残業時間を計算して返します。
 def overtime_calculation(designated_work_end_time)
  if nextday # 翌日にチェック(true)があれば残業終了時間に１日足して計算する 
    format("%.2f", (((self.end_time - designated_work_end_time) / 60) / 60.0))
  else
    format("%.2f", (((self.end_time - designated_work_end_time) / 60) / 60.0))
  end
 end
end
