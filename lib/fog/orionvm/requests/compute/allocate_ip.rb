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
        def allocate_ip(hostname, address = nil)
          body = {:friendly => hostname, :address => address}

          if address
            raise ArgumentError, "Address must be a valid IPv4 address" unless
              address =~ /\b(?:\d{1,3}\.){3}\d{1,3}\b/
          end

          post('allocate_ip', body, {:response_type => :hash})
        end
      end

      class Mock

        def allocate_ip(hostname, address=nil)
          response = Excon::Response.new

          if address && address == '123.234.123.231'
            response.status = 409
            raise(Excon::Errors.status_error({:expects => 200}, response))
          elsif address
            response.status = 200
            response.body = {'ip' => address}
          elsif hostname == 'example.com' || hostname =~ /^test/
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
