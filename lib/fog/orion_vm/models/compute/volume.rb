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

        attribute :server

        def initialize(attributes = {})
          # assign server first to prevent race condition with new_record?
          self.server = attributes.delete(:server)
          super
        end

        def destroy
          return false if locked?
          requires :id

          connection.drop_disk(id).body.eql?(true)
        end

        def save
          raise Fog::Errors::Error.new('Resaving an existing object will cause a failure') if identity

          requires :size

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

          if @server
            self.server = @server
          end

          merge_attributes(new_attributes)

          true
        end

        def ready?
          !locked?
        end

        def locked?
          locked.eql?(true)
        end

        # def server
        #   requires :server_id
        #   connection.vm_pool()
        # end

        def server=(new_server)
          if new_server
            attach(new_server)
          else
            detach
          end
        end

        def attach(new_server, read_only = false)
          if new_record?
            @server = new_server
          else
            @server = nil
            self.server = new_server
            connection.attach_disk(new_server.id, id, 'xvda1', read_only)
          end
        end

        def next_device_offset
        end

        def detach
          connection.detach_disk(server.id, id)
        end

      end

    end
  end
end

