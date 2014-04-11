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

        attribute :server_id, :aliases => 'vm'

        def initialize(attributes = {})
          # assign server first to prevent race condition with !persisted?
          self.server = attributes.delete(:server)
          super
          if persisted?
            self.name = id
          end
        end

        def destroy
          return false if locked?
          requires :id
          service.drop_disk(id).body.eql?(true)
        rescue Excon::Errors::Forbidden
          nil
        end

        def save
          raise Fog::Errors::Error.new('Resaving an existing object will cause a failure') if identity

          requires :size, :name

          if attributes.has_key?(:image)
            # We're 'cloning' a base image
            if service.deploy_disk(name, image, size).body.eql?(true)
              new_attributes = service.disk_pool({:name => name}).body.first
            end
          else
            # We're creating a clean image
            if service.create_disk(name, size).body.eql?(true)
              new_attributes = service.disk_pool({:name => name}).body.first
            end
          end

          if !new_attributes
            return false
          end
          
          merge_attributes(new_attributes)

          wait_for(30*60) { ready? }

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
          service.servers.get(server_id)
        end


        def server=(new_server, target = nil)
          if new_server
            attach(new_server, false, target)
          else
            detach
          end
        end

        def attach_server(new_server, target = nil)
          attach(new_server, false, target)
        end

        def attach(new_server, read_only = false, target = nil)
          if !persisted?
            @server = new_server
          else
            @server = nil
            self.server_id = new_server.id
            
            if !target
              disk_count = new_server.disks.count
              if new_server.vm_type == "HVM"
                target = "hd" + to_alph(disk_count+1)
              else
                target = "xvda" + (disk_count+1).to_s
              end
            end
            
            service.attach_disk(server_id, id, target, read_only)
          end
        end

        def detach
          unless !persisted?
            service.detach_disk(server_id, id).body.eql?(true)
          end
        end

      
      private
      
        Alph = ("a".."z").to_a
        def to_alph(num)
          s, q = "", num
          (q, r = (q - 1).divmod(26)) && s.prepend(Alph[r]) until q.zero?
          s
        end

      end
    end
  end
end

