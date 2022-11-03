module AttendancesHelper
  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出勤' if attendance.started_at.nil?
      return '退勤' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    # どれにも当てはまらなかった場合はfalseを返します。
    return false
  end

  # 出勤時間と退勤時間を受け取り、在社時間を計算して返します。
  def working_times(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0))
  end

 # 残業終了時間と指定勤務終了時間を受け取り、残業時間を計算して返します。
 def overtime_calculation(end_time, designated_work_end_time)
  if attendance.nextday # 翌日にチェックがあれば残業終了時間に２４時間足して計算する
    format("%.2f", (((end_time + 24 - designated_work_end_time) / 60) / 60.0))
  else
    format("%.2f", (((end_time - designated_work_end_time) / 60) / 60.0))
  end
 end
end 
