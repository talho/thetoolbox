l_file      = RAILS_ROOT + "/config/ldap.yml"
LDAP_Config = HashWithIndifferentAccess.new
if File.exists?(l_file)
  LDAP_Config.merge! YAML.load(IO.read(l_file))[RAILS_ENV]
end