module ClassesHelper
  def get_percent count
    (count.to_f / @total * 100).round(1)
  end
end
