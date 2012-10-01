require 'fog/core/model'

module Fog
  module Compute
    class OrionVM

      class Volume < Fog::Model
        identity  :id, :aliases => 'name'
        attribute :name, :type => :string
        attribute :locked, :type => :boolean
        attribute :image, :type => :string
        attribute :size, :type => :integer

        attribute :server_id

        def initialize(attributes = {})
          # assign server first to prevent race condition with new_record?
          self.server = attributes.delete(:server)
          super
        end

        def destroy
          return false if locked?
          requires :id
          connection.drop_disk(id).body.eql?(true)
        rescue Excon::Errors::Forbidden
          nil
        end

        def save
          raise Fog::Errors::Error.new('Resaving an existing object will cause a failure') if identity

          requires :size, :name

          if attributes.has_key?(:image)
            # We're 'cloning' a base image
            if connection.deploy_disk(name, image, size).body.eql?(true)
              new_attributes = connection.disk_pool({:name => name}).body.first
            end
          else
            # We're creating a clean image
            if connection.create_disk(name, size).body.eql?(true)
              new_attributes = connection.disk_pool({:name => name}).body.first
            end
          end

          merge_attributes(new_attributes)

          wait_for { ready? }

          if @server
            self.server = @server
          end

          true
        end

        def ready?
          !locked?
        end

        def locked?
          locked.eql?(true)
        end

        def server
          connection.servers.get(server_id)
        end

        def server=(new_server)
          if new_server
            attach(new_server)
          else
            detach
          end
        end

        def attach(new_server, read_only = false, target = 'xvda1')
          if new_record?
            @server = new_server
          else
            @server = nil
            self.server_id = new_server.id
            connection.attach_disk(server_id, id, target, read_only)
          end
        end

        def next_device_offset
        end

        def detach
          unless new_record?
            connection.detach_disk(server_id, id).body.eql?(true)
          end
        end

      end
    end
  end
end

