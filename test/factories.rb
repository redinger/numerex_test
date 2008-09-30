Factory.sequence :name do |n|
  "John#{n}"
end

Factory.sequence :device_name do |n|
  "Device #{n}"
end

Factory.define :user do |u|
  u.first_name { Factory.next(:name) }
  u.last_name "Smith"
  u.password "qwerty"
  u.email {|a| "#{a.first_name}.#{a.last_name}@example.com".downcase }
  u.account {|account| account.association(:account, :company=> 'Acme')}
end

Factory.define :account do |a|
  a.company "Acme"
  a.zip '75001'
  a.subdomain {|a| a.company}
end

Factory.define :device do |d|
  d.imei "1234567890"
  d.name {Factory.next(:device_name)}
  d.account {|account| account.association(:account, :company => 'Acme')}
end

Factory.define :reading do |r|
  r.device {|device| device.association(:device, :imei => "1234567890")}
end