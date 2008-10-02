Factory.sequence :name do |n|
  "John#{n}"
end

Factory.sequence :device_name do |n|
  "Device #{n}"
end

Factory.sequence :group_name do |n|
  "Group#{n}"
end

Factory.sequence :company_name do |n|
  "Company#{n}"
end

Factory.sequence :imei do |n|
  "#{n}"
end

Factory.sequence :profile_name do |n|
  "profile#{n}"
end

Factory.define :user do |u|
  u.first_name { Factory.next(:name) }
  u.last_name "Smith"
  u.password "qwerty"
  u.email {|a| "#{a.first_name}.#{a.last_name}@example.com".downcase }
  u.account {|account| account.association(:account)}
end

Factory.define :account do |a|
  a.company {Factory.next(:company_name)}
  a.zip '75001'
  a.subdomain {|a| a.company}
end

Factory.define :device do |d|
  d.imei {Factory.next(:imei)}
  d.name {Factory.next(:device_name)}
  d.last_online_time Time.now
  d.online_threshold 90
  d.provision_status_id 1
  d.account {|account| account.association(:account)}
end

Factory.define :reading do |r|
  r.device {|device| device.association(:device, :imei => "1234567890")}
end

Factory.define :group do |g|
  g.name { Factory.next(:group_name)}
  g.account {|account| account.association(:account)}
end

Factory.define :group_notification do |gn|
  gn.group {|group| group.association(:group)}
  gn.user {|user| user.association(:user)}
end

Factory.define :device_profile do |dp|
  dp.name {Factory.next(:profile_name)}
  dp.gpio1_labels "gpio1\tlow\thigh\tlow_notice\thigh_notice"
  dp.gpio2_labels "gpio2\tlow\thigh\tlow_notice\thigh_notice"
end
