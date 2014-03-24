module Fog
  module Compute
    class OrionVM
      class Real

        def create_vnc(vm_id, token)
          body = {:vmid => vm_id, :auth_token => token}

          post('vnc', body, {:response_type => :hash})
        end

      end

      class Mock
        def create_vnc(vm_id, auth_token)
          response = Excon::Response.new

          response.status = 200
          response.body = {
            :auth_token => auth_token,
            :vmid => vm_id,
            :vnc_host => "vnc01.orionvm.net.au",
            :port => 32783
          }

          response
        end
      end

    end
  end
end

