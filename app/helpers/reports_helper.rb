module ReportsHelper
  def minutes_to_hours(min)
    if min < 60
      (min % 60).to_s + " min"
    else
      hr = min / 60
      hr.to_s + (hr == 1 ? " hr" : " hrs") + ", " + (min % 60).to_s + " min"
    end
  end
  
  def total_miles(readings)
    total = 0
    for i in (0..readings.size)
      if i < readings.size-1
        total = total + readings[i].distance_to(readings[i+1])
      end
    end
    total
  end

end
