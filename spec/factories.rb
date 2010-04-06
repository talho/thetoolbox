require 'factory_girl'

Factory.define :user do |pp|
  pp.sequence(:login) {|i| "user#{i}"}
  pp.dn {|p| "CN=#{p.login}"}
end