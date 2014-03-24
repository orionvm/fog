require 'fog/core/model'

module Fog
  module Compute
    class OrionVM

      class Address < Fog::Model
        identity  :id,              :aliases => 'ip', :type => :string

        attribute :locked,          :type => :boolean
        attribute :server_id,       :aliases => 'vmid', :type => :integer
        attribute :bandwidth_up,    :aliases => 'up', :type => :float
        attribute :bandwidth_down,  :aliases => 'down', :type => :float
        attribute :hostname,        :aliases => 'friendly', :type => :string

        # Only used during allocation
        attribute :address

        def initialize(attributes = {})
          # assign server first to prevent race condition with new_record?
          self.server = attributes.delete(:server)
          super
        end

        def ready?
          !!identity
        end

        def server=(new_server)
          if new_server
            associate(new_server)
          else
            disassociate
          end
        end

        def server
          server_id ? connection.servers.get(server_id) : nil
        end

        def destroy
          requires :id
          connection.drop_ip(id).body.eql?(true)
        end

        def save
          raise Fog::Errors::Error.new('Resaving an existing object will cause a failure') if identity

          requires :hostname

          new_attributes = connection.allocate_ip(hostname, address).body
          merge_attributes(new_attributes)

          if @server
            self.server = @server
          end

          true
        end

        def disassociate
          unless new_record?
            requires :server_id
            connection.detach_ip(server_id, id)
          end
          @server = nil
          self.server_id = nil
        end

        private

        def associate(new_server)
          if new_record?
            @server = new_server
          else
            @server = nil
            self.server_id = new_server.id
            connection.attach_ip(server_id, id)
          end
        end

      end

    end
  end
end

