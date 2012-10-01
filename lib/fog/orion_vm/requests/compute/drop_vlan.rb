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
        def drop_vlan(id)
          post('drop_vlan', {:vlan => id}, {:response_type => :boolean})
        end
      end

      class Mock

        def drop_vlan(id)
          response = Excon::Response.new
          response.body = ''
          response.status = 200
          response
        end

      end
    end
  end
end
