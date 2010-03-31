file = RAILS_ROOT + "/config/ldap.yaml"
LDAP_Config=HashWithIndifferentAccess.new
if File.exists?(file)
  LDAP_Config.merge! YAML.load(IO.read(file))
end