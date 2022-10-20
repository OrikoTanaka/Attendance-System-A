module UsersHelper

  # 勤怠基本情報を指定のフォーマットで返します。7：30→7.50  
  def format_basic_info(time)
    format("%.2f", ((time.hour * 60) + time.min) / 60.0)
  end
end