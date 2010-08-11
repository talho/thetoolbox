class ExchangeUser < ActiveResource::Base

  headers['Content-Type'] = 'application/soap+xml'

  class << self
    def element_path(id, prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{collection_name}/#{id}#{query_string(query_options)}"
    end

    def collection_path(prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{collection_name}/#{query_string(query_options)}"
    end
  end


  self.primary_key :login
  self.site = "http://adtest2008/"
  self.element_name = "ExchSvc"

  def id
    login if self.attributes.keys.include?("login")
  end

  def destroy
    self.post(:delete)  
  end

  def update
    self.post(:update, nil, self.to_xml)
  end

  def self.all
    self.find(:all)
  end

  def has_vpn_account?
    self.has_vpn.downcase ==  "true"
  end

  def contact
    self.get(:contact, {:email => self.email, :dn => self.cn})
  end
end