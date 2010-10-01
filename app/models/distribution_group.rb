class DistributionGroup < ActiveResource::Base

  headers['Content-Type'] = 'application/xml'

  class << self
    def element_path(id, prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{collection_name}/#{ERB::Util.url_encode(id)}#{query_string(query_options)}"
    end

    def collection_path(prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{collection_name}/#{query_string(query_options)}"
    end
  end


  self.site = "http://ad3.talho.net/"
  self.element_name = "DstrSvc"

  def self.all
    self.find(:all)
  end

  def update
    self.post(:update, nil, self.to_xml) #send the update to /#id/update with the xml representation as the body
  end

  def delete
    self.post(:delete, nil, self.to_xml) #send the delete as a post to /#id/delete
  end
end