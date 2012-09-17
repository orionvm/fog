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
          server = create(new_attributes)
          server.wait_for { ready? }

          server.addresses.create(:hostname => hostname)

          # connection.allocate_ip
          # connection.deploy_disk(hostname, 'ubuntu-lucid', 50)
          # connection.attach_disk()


          # server.setup(:key_data => [server.private_key])
          server
        end

        def all(filters = {})
          self.filters = filters
          load(servers)
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

