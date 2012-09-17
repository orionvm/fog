module Fog
  module Compute
    class OrionVM
      class Real
        
        # Allocates an IP Address object
        #
        # ==== Parameters
        # * hostname<~String> - A unqiue name to reference this IP Address object.
        #   It is a good idea to make this the same as the FQHN which will be associated
        #   with it.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>
        #     * ip<~String
        def allocate_ip(hostname)
          body = {:friendly => hostname}
          post('allocate_ip', body, {:response_type => :hash})
        end
      end
      
      class Mock
        
        def allocate_ip(hostname)
          response = Excon::Response.new
          
          if hostname == 'example.com'
            response.status = 200
            response.body = {'ip' => '123.234.123.234'}
          else
            response.status = 404
            raise(Excon::Errors.status_error({:expects => 200}, response))
          end
          response
        end
        
      end
      
    end
  end
end
