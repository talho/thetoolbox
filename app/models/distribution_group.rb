class DistributionGroup < ActiveResource::Base

  headers['Content-Type'] = 'application/soap+xml'

  class << self
    def element_path(id, prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{collection_name}/#{CGI.escape(id)}#{query_string(query_options)}"
    end

    def collection_path(prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{collection_name}/#{query_string(query_options)}"
    end
  end


  self.primary_key :name
  self.site = "http://adtest2008/"
  self.element_name = "DstrSvc"

  def id
    name if self.attributes.keys.include?("name")
  end

  def self.all
    self.find(:all)
  end

end