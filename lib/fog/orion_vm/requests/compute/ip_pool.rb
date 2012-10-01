module Fog
  module Compute
    class OrionVM
      class Real

        def ip_pool(filters = nil, options = nil)
          filters ||= {}
          options ||= {}
          response = get('ip_pool', options)

          unless filters.empty? || response.body.empty?
            filters.each do |filter, requirement|
              if response.body.all? { |ip| ip.keys.include?(filter.to_s) }
                response.body = response.body.select { |ip| ip[filter.to_s] == requirement }
              end
            end
          end

          response
        end

      end

      class Mock
        def ip_pool(filters = nil)
          response = Excon::Response.new.tap do |response|
            response.status = 200
            response.body = [
              {
                'locked' => true,
                'ip' => "49.156.19.56",
                'vmid' => 841,
                'up' => 0,
                'down' => 0,
                'friendly' => "test.fog_server"
              },
              {
                'down' => 0,
                'ip' => "156.17.23.28",
                'locked' => false,
                'friendly' => "vnctest",
                'up' => 0
              },
              {
                'down' => 0,
                'ip' => "123.234.123.234",
                'locked' => false,
                'friendly' => "test.address",
                'up' => 0
              }
            ]
          end

          unless filters.empty? || response.body.empty?
            filters.each do |filter, requirement|
              if response.body.all? { |disk| disk.keys.include?(filter.to_s) }
                response.body = response.body.select { |disk| disk[filter.to_s] == requirement }
              end
            end
          end

          response
        end
      end
    end
  end
end
