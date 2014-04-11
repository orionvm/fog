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
          response = Excon::Response.new
          ip = self.data[:ips][ip_address]
          vm = self.data[:instances][vm_id]
          if ip && vm && !ip['locked']
            ip['locked'] = true
            ip['vmid'] = vm_id
            vm['ips'].push(ip_address)
            
            Fog::Logger.debug "attaching IP #{ip_address}" 
            response.status = 200
            response.body = true
            return response
          end

          response.status = 400
          response.body = 'Invalid input: HTTP 400: Bad Request {Reason}'
          Fog::Logger.debug "ip failed to attach " + ip.inspect + vm.inspect
          raise(Excon::Errors.status_error({:expects => 200}, response))
        end
        
      end
    end
  end
end
