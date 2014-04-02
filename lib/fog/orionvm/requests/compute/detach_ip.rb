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
          ip = self.data[:ips][ip_address]
          vm = self.data[:instances][vm_id]
          if ip && vm
            if ip['locked'] && ip['vmid'] == vm_id
              ip['locked'] = false
              ip.delete('vmid')
              vm['ips'].delete(ip_address)
              response.status = 200
              response.body = true
              return response
            end   
          end

          response.status = 400
          response.body = 'Invalid input: HTTP 400: Bad Request {Reason}'
          raise(Excon::Errors.status_error({:expects => 200}, response))
        end
      end

    end
  end
end
