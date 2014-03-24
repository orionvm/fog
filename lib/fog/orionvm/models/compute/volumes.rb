require 'fog/core/collection'
require 'fog/orionvm/models/compute/volume'

module Fog
  module Compute
    class OrionVM

      class Volumes < Fog::Collection
        attribute :filters
        attribute :server

        model Fog::Compute::OrionVM::Volume

        def initialize(attributes)
          self.filters ||= {}
          super(attributes)
        end

        def all(filters = {})
          self.filters = filters
          load(volumes(filters))

          if server
            replace(select { |volume|
                server.disks.map { |disk| disk['name'] }.include?(volume.id)
              }
            )
          end

          self
        end

        def get(volume_id)
          new volumes(:name => volume_id).first
        rescue Fog::Compute::OrionVM::NotFound
          nil
        end

        def new(attributes = nil)
          attributes ||= {}
          if server && server.persisted?
            attributes.merge!(:server => server)
            attributes.merge!(:server_id => server.id)
            attributes.merge!(:name => server.hostname) unless attributes.has_key?(:name)
          end
          super(attributes)
        end

        private

        def volumes(filters = self.filters)
          connection.disk_pool(filters).body
        end

      end
    end
  end
end
