module Fog
  module Compute
    class OrionVM
      class Real

        # Allocates a VLAN
        #
        # ==== Parameters
        # none
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * vlan_id<~Integer>
        def detach_vlan(vm_id, vlan_id)
          post('detach_vlan', {:vmid => vm_id, :vlan => vlan_id}, {:response_type => :boolean})
        end
      end

      class Mock

        def detach_vlan(vm_id, vlan_id)
          response = Excon::Response.new
          response.body = ''
          response.status = 200
          response
        end

      end
    end
  end
end
