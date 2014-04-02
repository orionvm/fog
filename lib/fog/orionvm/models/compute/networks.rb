require 'fog/core/collection'
require 'fog/orionvm/models/compute/network'

module Fog
  module Compute
    class OrionVM

      class Networks < Fog::Collection
        attribute :filters
        attribute :server

        model Fog::Compute::OrionVM::Network

        def initialize(attributes)
          self.filters ||= {}
          super(attributes)
        end

        def all(filters = {})
          self.filters = filters

          if server && server.persisted?
            self.filters.merge!(:vmids => [server.id])
          end

          load(networks(filters))

          if server
            replace(select {|network| network.server_ids.include?(server.id) })
          end

          self
        end

        def get(id)
          new networks(:id => id).first
        rescue Fog::Compute::OrionVM::NotFound
          nil
        end

        def new(attributes = {})
          if server && server.persisted?
            attributes.merge!(:server => server)
          end
          super(attributes)
        end

        private

        def networks(filters = self.filters)
          service.vlan_pool(filters).body
        end

      end

    end
  end
end


