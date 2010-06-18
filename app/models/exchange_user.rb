class ExchangeUser < ActiveResource::Base

  headers['Content-Type'] = 'application/soap+xml'

  class << self
    def element_path(id, prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil? 
      "#{prefix(prefix_options)}#{collection_name}/#{CGI.escape(id).gsub(/\./,"%2E")}#{query_string(query_options)}"
    end

    def collection_path(prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{collection_name}/#{query_string(query_options)}"
    end
  end


  self.primary_key :upn
  self.site = "http://adtest2003/"
  self.element_name = "Service1"

  def id
    upn if self.attributes.keys.include?("upn")
  end

  def destroy
    self.post(:delete)  
  end
end