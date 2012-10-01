module Fog
  module Compute
    class OrionVM
      class Real

        # Allocates an IP Address object
        #
        # ==== Parameters
        # * vm_id<~Integer> - The VM to attach the IP Address object to.
        # * ip_address<~String> - The IP Address object.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Boolean>
        def attach_ip(vm_id, ip_address)
          body = {:vmid => vm_id, :ip => ip_address}

          post('attach_ip', body, {:response_type => :boolean})
        rescue Excon::Errors::Forbidden => e
          nil
        end

      end

      class Mock
        def attach_ip(vm_id, ip_address)
          Excon::Response.new.tap do |response|
            if vm_id && ip_address
              response.status = 200
              response.body = true
            else
              response.status = 404
              raise(Excon::Errors.status_error({:expects => 200}, response))
            end
          end
        end
      end
    end
  end
end
