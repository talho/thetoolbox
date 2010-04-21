l_file      = RAILS_ROOT + "/config/white_list.yml"
SPAM_Config = HashWithIndifferentAccess.new
if File.exists?(l_file)
  SPAM_Config.merge! YAML.load(IO.read(l_file))[RAILS_ENV]
end