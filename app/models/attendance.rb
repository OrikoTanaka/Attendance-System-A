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
    if self.nextday # 翌日にチェック(true)があれば残業終了時間に１日足して計算する 
      format("%.2f", (((self.end_time - designated_work_end_time) / 60) / 60.0))
    else
      format("%.2f", (((self.end_time - designated_work_end_time) / 60) / 60.0))
    end
  end

  # 勤怠ページにて残業申請後の現在の上長確認結果を表示
  def result_of_overtime_request
    if self.overtime_request_status.present?
      if self.overtime_request_status = "申請中"
        return "#{self.confirmer}へ申請中"
      elsif self.overtime_request_status = "承認"
        return "残業承認済"
      elsif self.overtime_request_status = "否認"
        return "残業否認"
      elsif self.overtime_request_status = "なし"
        return ""
      end
    end
  end

  # 勤怠ページにて一ヶ月分の勤怠申請の現在の上長確認結果を表示
  def result_of_onemonth_request
    if self.onemonth_request_status.present?
      if self.onemonth_request_status = "申請中"
        return "#{self.onemonth_confirmer}へ申請中"
      elsif self.onemonth_request_status = "承認"
        return "#{self.onemonth_confirmer}から承認済"
      elsif self.onemonth_request_status = "否認"
        return "勤怠否認"
      elsif self.onemonth_request_status = "なし"
        return "所属長承認　未"
      end
    else
      "所属長承認　未"
    end
  end

  # 残業申請の退勤時間の更新
  def self.finish_at_update(user, designated_work_end_time)
    notice_overtime_params.each do |id, item|
      attendance = Attendance.find(id)
      if self.approval
        if self.overtime_request_status = "承認"
          self.finished_at = self.end_time
          self.end_time = nil
          self.nextday = false
          self.approval = false
          self.confirmer = nil
        else self.overtime_request_status = "否認" || "なし"
          self.finished_at = designated_work_end_time
          self.end_time = nil
          self.nextday = false
          self.approval = false
          self.confirmer = nil
        end
        attendance.attributes = item
        attendance.save
        flash[:success] = "変更を送信しました。"
        redirect_to user_url(current_user)
      else 
        redirect_to user_url(current_user)
      end
    end
  end

   # 残業申請の承認情報
  def notice_overtime_params
    params.require(:user).permit(attendances: [:overtime_request_status, :approval])[:attendances]
  end
end
