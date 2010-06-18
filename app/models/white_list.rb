class WhiteList < ActiveResource::Base
  self.primary_key :prefid
  self.site = Proc.new {
    uri_prefix = SPAM_Config[:secure] ? "https://" :"http://"
    the_site   = "#{uri_prefix}#{SPAM_Config[:username]}:#{SPAM_Config[:password]}@#{SPAM_Config[:host]}"
    the_site  += ":#{SPAM_Config[:port]}" if SPAM_Config[:port]
    the_site
  }.call
  
  def id
    prefid if self.attributes.keys.include?("prefid")
  end
  
end