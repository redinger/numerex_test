class DeviceProfile < ActiveRecord::Base
  has_many :devices,:foreign_key => 'profile_id'
  
  def gpio1_name
    gpio1_split[GPIO_NAME]
  end
  
  def gpio1_low_value
    gpio1_split[GPIO_LOW_VALUE]
  end
  
  def gpio1_high_value
    gpio1_split[GPIO_HIGH_VALUE]
  end
  
  def gpio1_low_notice
    gpio1_split[GPIO_LOW_NOTICE]
  end
  
  def gpio1_high_notice
    gpio1_split[GPIO_HIGH_NOTICE]
  end
  
  def gpio1_low_status
    gpio1_split[GPIO_LOW_STATUS]
  end
  
  def gpio1_high_status
    gpio1_split[GPIO_HIGH_STATUS]
  end
  
  def gpio2_name
    gpio2_split[GPIO_NAME]
  end
  
  def gpio2_low_value
    gpio2_split[GPIO_LOW_VALUE]
  end
  
  def gpio2_high_value
    gpio2_split[GPIO_HIGH_VALUE]
  end
  
  def gpio2_low_notice
    gpio2_split[GPIO_LOW_NOTICE]
  end
  
  def gpio2_high_notice
    gpio2_split[GPIO_HIGH_NOTICE]
  end
  
  def gpio2_low_status
    gpio2_split[GPIO_LOW_STATUS]
  end
  
  def gpio2_high_status
    gpio2_split[GPIO_HIGH_STATUS]
  end
  
  def update_gpio_attributes(watch,labels,name,low_value,high_value,low_notice,high_notice,low_status,high_status)
    combined_values = "#{name}\t#{low_value}\t#{high_value}\t#{low_notice}\t#{high_notice}\t#{low_status}\t#{high_status}" unless name.blank?
    update_attribute(labels,combined_values)
    update_attribute(watch,(combined_values and not (low_notice.blank? and high_notice.blank?)))
    reset_gpio
    true
  end

private
  GPIO_NAME = 0
  GPIO_LOW_VALUE = 1
  GPIO_HIGH_VALUE = 2
  GPIO_LOW_NOTICE = 3
  GPIO_HIGH_NOTICE = 4
  GPIO_LOW_STATUS = 5
  GPIO_HIGH_STATUS = 6
  
  def gpio1_split
    @gpio1_split ||= split_labels_without_empty_strings(gpio1_labels)
  end
  
  def gpio2_split
    @gpio2_split ||= split_labels_without_empty_strings(gpio2_labels)
  end
  
  def reset_gpio
    @gpio1_split = nil
    @gpio2_split = nil
  end
  
  def split_labels_without_empty_strings(labels)
    (labels or '').split("\t").collect {|label| label unless label.blank?}
  end
end
