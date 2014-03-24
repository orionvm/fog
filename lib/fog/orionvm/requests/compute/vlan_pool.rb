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
        def vlan_pool(filters = {})
          response = get('vlan_pool', {:response_type => :array})

          # response.body = response.body.map { |object| object['vmids'] = object['vmids'].map { |v| {'vm_id' => v} }; object }

          unless filters.empty? || response.body.empty?
            filters.each do |filter, requirement|
              if response.body.all? { |vlan| vlan.keys.include?(filter.to_s) }
                response.body =
                  response.body.select { |o| Array(requirement).include?(o[filter.to_s]) }
              end
            end
          end

          response
        end
      end

      class Mock

        def vlan_pool(filters = {})
          response = Excon::Response.new
          response.body = [251, 203, 204, 205, 206, 207, 208, 209, 210, 211]
          response.status = 200

          response.body = response.body.map { |id| {:id => id} }

          unless filters.empty? || response.body.empty?
            filters.each do |filter, requirement|
              if response.body.all? { |vlan| vlan.keys.include?(filter.to_sym) }
                response.body = response.body.select { |o| o[filter.to_sym] == requirement }
              end
            end
          end

          response
        end

      end
    end
  end
end
