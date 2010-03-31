file = RAILS_ROOT + "/config/ldap.yml"
LDAP_Config=HashWithIndifferentAccess.new
if File.exists?(file)
  LDAP_Config.merge! YAML.load(IO.read(file))[RAILS_ENV]
end