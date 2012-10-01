require 'fog/core/collection'
require 'fog/orion_vm/models/compute/address'

module Fog
  module Compute
    class OrionVM

      class Addresses < Fog::Collection
        attribute :filters
        attribute :server

        model Fog::Compute::OrionVM::Address

        def initialize(attributes)
          self.filters ||= {}
          super(attributes)
        end

        def all(filters = {})
          self.filters = filters

          if server && !server.new_record?
            self.filters.merge!(:vmid => server.id)
          end

          load(addresses(filters))

          if server
            replace(select {|address| address.server_id == server.id})
          end

          self
        end

        def get(ip_address)
          if address = addresses(:ip => ip_address).first
            new(address)
          end
        rescue Fog::Compute::OrionVM::NotFound
          nil
        end

        def new(attributes = nil)
          attributes ||= {}
          if server && !server.new_record?
            attributes.merge!(:server => server)
            attributes.merge!(:hostname => server.hostname) unless attributes.has_key?(:hostname)
          end
          super(attributes)
        end

        private

        def addresses(filters = self.filters)
          connection.ip_pool(filters).body
        end

      end

    end
  end
end

