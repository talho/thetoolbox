module ActiveResource
  module CustomMethods
    module InstanceMethods
      private
        def custom_method_element_url(method_name, options = {})
          begin
            "#{self.class.prefix(prefix_options)}#{self.class.collection_name}/#{ERB::Util.url_encode(id).gsub(/\./,"%2E")}/#{method_name}#{self.class.__send__(:query_string, options).gsub(/\./, "%2E")}"
          rescue
            "#{self.class.prefix(prefix_options)}#{self.class.collection_name}/#{ERB::Util.url_encode(id).gsub(/\./,"%2E")}/#{method_name}#{self.class.__send__(:query_string, options)}"  
          end
        end
    end
  end
end
