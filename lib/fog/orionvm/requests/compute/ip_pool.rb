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
          response = Excon::Response.new.tap do |r|
            r.status = 200
            r.body = self.data[:ips].values
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
