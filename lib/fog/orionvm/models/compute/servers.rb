require 'fog/core/collection'
require 'fog/orion_vm/models/compute/server'

module Fog
  module Compute
    class OrionVM

      class Servers < Fog::Collection
        attribute :filters

        model Fog::Compute::OrionVM::Server

        def initialize(attributes)
          self.filters ||= {}
          super(attributes)
        end

        def bootstrap(new_attributes = {})
          image = new_attributes.delete(:image) || 'ubuntu-oneiric'
          size = new_attributes.delete(:size) || 50

          server = create(new_attributes)

          address = server.addresses.create
          address.wait_for { ready? }

          volume = server.volumes.create(:image => image, :size => size)

          server.setup

          server.start
          server.wait_for { ready? }
          server
        end

        def all(filters = {})
          filters = self.filters.merge(filters)

          load(servers(filters))

          self
        end

        # Returns a single instance of server, or nil if it can't be found.
        #
        # ==== Parameters
        # * server_id<~String/Integer> - Can either be the unqiue ID as an Integer,
        #   or the hostname of the instance.
        #
        # ==== Returns
        # * Fog::Compute::OrionVM::Server<~Fog::Compute::OrionVM::Server>
        # def get(server_id)
        #   if server_id.to_i.to_s == server_id.to_s
        #     new servers(:vm_id => server_id).first
        #   elsif server_id.is_a?(String)
        #     new servers(:hostname => server_id).first
        #   end

        # rescue Fog::Compute::OrionVM::NotFound
        #   nil
        # end

        def get(server_id)
          if server_id.is_a?(Integer) && server_id.to_i == server_id
            self.class.new(:connection => connection).all(:vm_id => server_id.to_i).first
          elsif server_id.is_a?(String)
            self.class.new(:connection => connection).all(:hostname => server_id).first
          end
        rescue Fog::Errors::NotFound
          nil
        end

        private

        def servers(filters = self.filters)
          connection.vm_pool(filters).body
        end

      end

    end
  end
end

