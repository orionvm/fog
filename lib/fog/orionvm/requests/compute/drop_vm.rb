module Fog
  module Compute
    class OrionVM
      class Real

        def drop_vm(vm_id, options = nil)
          options ||= {}
          post('drop_vm', {:vmid => vm_id}, {:response_type => :boolean}.merge(options))
        end

      end

      class Mock
        def drop_vm(vm_id, options = nil)
          response = Excon::Response.new

          if vm_id
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
