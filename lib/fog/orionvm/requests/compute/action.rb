module Fog
  module Compute
    class OrionVM
      class Real

        # Calls an action on a VM
        #
        # ==== Parameters
        # * vm_id<~Integer> - The ID of a VM
        # * command<~String> - A command
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Boolean>
        def action(vm_id, command)
          body = {:vmid => vm_id, :action => command}
          post('action', body, {:response_type => :boolean})
        end
      end

      class Mock

        def action(vm_id, command)
          response = Excon::Response.new
          errors = []
          
          vm = self.data[:instances][vm_id]
          if vm
            if command == "shutdown"
              if vm['state'] == 2
                vm['state'] = 0
                response.status = 200
                response.body = true
              else
                errors.push("vm state: #{vm['state']} is not appropriate for shutdown")
              end
            else
              errors.push("unknown command: #{command}")
            end
          else
            errors.push("Invalid vm_id or no vm found: #{vm_id}")
          end
          
          if errors.count > 0
            STDERR.puts errors
            response.status = 400
            raise(Excon::Errors.status_error({:expects => 200}, response))
          end
          response
        end
      end

    end
  end
end
