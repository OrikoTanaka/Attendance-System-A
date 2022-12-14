class Attendance < ApplicationRecord
  belongs_to :user

  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  validates :end_time, :overtime_reason, :confirmer, presence: true, on: :update_request_overtime
  validates :onemonth_confirmer, presence: true, on: :request_onemonth

  # 指示者確認印があり出勤時間が存在しない場合、退勤時間は無効
  validate :finished_at_after_change_is_invalid_without_a_started_at_after_change
  
  # 出勤・退勤時間どちらも存在する時、翌日チェックがない時,指示者確認印がある時、出勤時間より早い退勤時間は無効
  validate :started_at_after_change_than_finished_at_after_change_fast_if_invalid

  # 出勤時間が存在、退勤時間が存在しない時、更新は無効
  validate :started_at_after_change_is_invalid_withiout_a_finished_at_after_change, on: :update_one_month # update_one_monthのアクション実行の時のみバリデーションをかける

  def finished_at_after_change_is_invalid_without_a_started_at_after_change
    errors.add(:started_at_after_change, "が必要です") if started_at_after_change.blank? && finished_at_after_change.present? && attendance_change_confirmer.present?
  end

  def started_at_after_change_than_finished_at_after_change_fast_if_invalid
    if started_at_after_change.present? && finished_at_after_change.present? && !nextday.present? && attendance_change_confirmer.present?
      errors.add(:finished_at_after_change, "出勤時間より早い退勤時間は無効です") if started_at_after_change > finished_at_after_change
    end
  end

  def started_at_after_change_is_invalid_withiout_a_finished_at_after_change
    errors.add(:finished_at_after_change, "が必要です") if started_at_after_change.present? && finished_at_after_change.blank? && attendance_change_confirmer.present?
  end

    # 残業終了時間と指定勤務終了時間を受け取り、残業時間を計算して返します。
  def overtime_calculation(designated_work_end_time)
    if self.nextday # 翌日にチェック(true)があれば残業終了時間に１日足して計算する 
      format("%.2f", ((self.end_time.hour - designated_work_end_time.hour) + (self.end_time.min - designated_work_end_time.min) / 60.0) +24)
    else
      format("%.2f", (self.end_time.hour - designated_work_end_time.hour) + (self.end_time.min - designated_work_end_time.min) / 60.0)
    end
  end

  # 残業申請の退勤時間の更新
  def self.finish_at_update(designated_work_end_time, notice_overtime_params)
    ActiveRecord::Base.transaction do
      notice_overtime_params.each do |id, item|
        attendance = Attendance.find(id)
        if item[:approval] == "1"# itemはハッシュなので、キーを指定することになる。そのためにはこの記述[]の仕方をする
          if item[:overtime_request_status] == "承認"
            attendance.finished_at = attendance.end_time
            attendance.approval = false
          else item[:overtime_request_status] == "否認" || "なし"
            attendance.finished_at = designated_work_end_time
            attendance.end_time = nil
            attendance.nextday = false
            attendance.approval = false
            attendance.overtime_reason = nil
          end
          attendance.attributes = item
          attendance.save!
        end
      end
    end
    true # トランザクションで保存に成功した場合、trueを返す
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    false # 保存（バリデーションに引っ掛かるなども）に失敗したらfalseを返す
  end

  # 勤怠時間の変更申請
  def self.time_change_request(attendances_params)
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.attendance_change_request_status = "申請中"
        if item[:started_at] = nil?
          attendance.started_at_first = attendance.started_at
        end
        if item[:finished_at] = nil?
          attendance.finished_at_first = attendance.finished_at
        end
        attendance.attributes = item #ここでオブジェクトのカラム全体を更新(この時点ではレコードに保存していない)
        attendance.save!(context: :update_one_month) #ここで↑で更新した値をレコードに保存(同時にバリデーションを実行)
      end
    end
    true # トランザクションで保存に成功した場合、trueを返す
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    false # 保存（バリデーションに引っ掛かるなども）に失敗したらfalseを返す
  end

  # 勤怠の出社・退社時間等の更新
  def self.attendance_time_update(notice_attendance_change_params)
    ActiveRecord::Base.transaction do
      notice_attendance_change_params.each do |id, item|
        attendance = Attendance.find(id)
        if item[:attendance_change_approval] == "1"# itemはハッシュなので、キーを指定することになる。そのためにはこの記述[]の仕方をする
          if item[:attendance_change_request_status] == "承認"
            attendance.started_at_first = attendance.started_at
            attendance.finished_at_first = attendance.finished_at
            attendance.started_at = attendance.started_at_after_change
            attendance.finished_at = attendance.finished_at_after_change
            attendance.attendance_change_approval = false
          else item[:attendance_change_request_status] == "否認" || "なし"
            attendance.started_at_after_change = nil
            attendance.finished_at_after_change = nil
            attendance.note = nil
            attendance.attendance_change_approval = false
          end
          attendance.attributes = item
          attendance.save!
        end
      end
    end
    true # トランザクションで保存に成功した場合、trueを返す
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    false # 保存（バリデーションに引っ掛かるなども）に失敗したらfalseを返す
  end
end
