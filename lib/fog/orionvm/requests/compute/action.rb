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
