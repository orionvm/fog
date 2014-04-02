require 'fog/core/model'

module Fog
  module Compute
    class OrionVM

      class Network < Fog::Model
        identity  :id
        attribute :server_ids, :type => :array, :aliases => 'vmids'
        attribute :server_id, :type => :integer

        def initialize(attributes = {})
          # assign server first to prevent race condition with !persisted?
          self.server = attributes.delete(:server)
          super
        end

        def ready?
          !!identity
        end

        def server=(new_server)
          if new_server
            attach(new_server)
          else
            detach
          end
        end

        def server
          service.servers.get(server_id)
        end

        def destroy
          requires :id
          service.drop_vlan(id).body.eql?(true)
        end

        def servers
          service.servers.all(:vm_id => server_ids)
        end

        def save
          raise Fog::Errors::Error.new('Resaving an existing object will cause a failure') if identity

          vlan_id = service.allocate_vlan.body
          merge_attributes({:id => vlan_id})

          if @server
            self.server = @server
          end

          true
        end

        def detach
          unless !persisted?
            requires :server_id
            service.detach_vlan(server_id, id)
          end
          @server = nil
          self.server_id = nil
        end

        def attach(new_server)
          if !persisted?
            @server = new_server
          else
            @server = nil
            self.server_id = new_server.id
            service.attach_vlan(server_id, id)
          end
        end

      end
    end
  end
end


