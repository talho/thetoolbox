module ActiveResource
  module CustomMethods
    module InstanceMethods
      private
        def custom_method_element_url(method_name, options = {})
          "#{self.class.prefix(prefix_options)}#{self.class.collection_name}/#{CGI.escape(id).gsub(/\./,"%2E")}/#{method_name}#{self.class.__send__(:query_string, options)}"
        end
    end
  end
end
