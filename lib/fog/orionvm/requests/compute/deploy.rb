module Fog
  module Compute
    class OrionVM
      class Real

        # Deploys (starts) a VM
        #
        # ==== Parameters
        # * vm_id<~Integer> - The ID of the VM you want to start.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Boolean>
        def deploy(vm_id, options = nil)
          options ||= {}
          post('deploy', {:vmid => vm_id}, options)
        end

        # VM States:
        # Normal States
        # 0 -> Not running
        # 2 -> Running
        #
        # Transition States
        # 1 -> Being booted
        # 3 -> Shutting down
        # 4 -> Being rebooted
        #
        # Error States
        # 11 -> Failed to boot
        # 13 -> Failed to shut down

      end

      class Mock
        def deploy(vm_id, options = nil)
          response = Excon::Response.new
          errors = []
          
          vm = self.data[:instances][vm_id]
          if vm
            if vm['state'] == 0
              vm['state'] = 2
              response.status = 200
              response.body = true
            else
              errors.push("vm state: #{vm['state']} is not appropriate for starting")
            end
          else
            errors.push("Invalid vm_id or no vm found: #{vm_id}")
          end
          
          if errors.count > 0
            Fog::Logger.warning errors.to_s
            response.status = 400
            raise(Excon::Errors.status_error({:expects => 200}, response))
          end
          response

        end
      end
    end
  end
end
