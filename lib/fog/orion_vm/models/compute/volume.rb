require 'fog/core/model'

module Fog
  module Compute
    class OrionVM

      class Volume < Fog::Model
        identity  :id, :aliases => 'name'

        attribute :locked
        attribute :image
        attribute :size

        attr_accessor :server

        def initialize(attributes = {})
          # assign server first to prevent race condition with new_record?
          self.server = attributes.delete(:server)
          super
        end

        def destroy
          requires :id

          connection.drop_disk(id).body.eql?(true)
        end

        def save
          # raise Fog::Errors::Error.new('Resaving an existing object will cause a failure') if identity

          requires :size, :id

          if attributes.has_key?(:image)
            # We're 'cloning' a base image
            if connection.deploy_disk(id, image, size).body.eql?(true)
              new_attributes = connection.disk_pool({:name => id}).body.first
            end
          else
            # We're creating a clean image

            if connection.create_disk(id, size).body.eql?(true)
              new_attributes = connection.disk_pool({:name => id}).body.first
            end
          end

          merge_attributes(new_attributes)

          true
        end

        def ready?
          locked.eql?(false)
        end

        # def server
        #   requires :server_id
        #   connection.vm_pool()
        # end

        # def server=(new_server)
        #   if new_server
        #     attach(new_server)
        #   else
        #     detach
        #   end
        # end

        def attach(server)
          connection.attach_disk(server.id, self.id, 'xvda1')
        end

        def detach
          connection.detach_disk(server.id, self.id)
        end

      end

    end
  end
end

