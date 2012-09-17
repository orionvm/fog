require 'fog/core/collection'
require 'fog/orion_vm/models/compute/volume'

module Fog
  module Compute
    class OrionVM

      class Volumes < Fog::Collection
        attribute :filters

        model Fog::Compute::OrionVM::Volume

        def initialize(attributes)
          self.filters ||= {}
          super(attributes)
        end

        def all(filters = {})
          self.filters = filters
          load(volumes(filters))
        end

        def get(volume_id)
          new volumes(:name => volume_id).first
        rescue Fog::Compute::OrionVM::NotFound
          nil
        end

        private

        def volumes(filters = self.filters)
          connection.disk_pool(filters).body
        end

      end

    end
  end
end
