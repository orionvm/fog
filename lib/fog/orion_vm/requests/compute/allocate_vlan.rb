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
        def allocate_vlan
          post('allocate_vlan', {}, {:response_type => :integer})
        end
      end

      class Mock

        def allocate_vlan
          response = Excon::Response.new
          response.body = 123
          response.status = 200
          response
        end

      end
    end
  end
end

