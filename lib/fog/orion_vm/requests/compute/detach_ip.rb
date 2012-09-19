module Fog
  module Compute
    class OrionVM
      class Real

        # Detaches an IP Address from a VM
        #
        # ==== Parameters
        # * vm_id<~Integer> - The ID of the VM to detach an IP address from.
        # * ip_address<~String> - The IP address to detach
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Boolean>
        def detach_ip(vm_id, ip_address)
          body = {:vmid => vm_id, :ip => ip_address}

          post('detach_ip', body, {:response_type => :boolean})
        end

      end

      class Mock
        def detach_ip(vm_id, ip_address)
          response = Excon::Response.new

          if vm_id == 1
            response.status = 200
            response.body = true
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
