module Fog
  module Compute
    class OrionVM
      class Real

        def disk_pool(filters = nil, options = nil)
          filters ||= {}
          options ||= {}
          response = get('disk_pool', options)

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

      class Mock
        def disk_pool(filters = nil, options = nil)
          response = Excon::Response.new.tap do |response|
            response.status = 200
            response.body = [
              {:name => "test.fog_server_1", :image => 'ubuntu-oneiric', :size => 50, :locked => false}
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
