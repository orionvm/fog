module Fog
  module Compute
    class OrionVM
      class Real

        # Attaches an existing disk to a VM at the given mount point
        #
        # ==== Parameters
        # * vm_id<~Integer> - The ID of the VM you want to attach this disk to
        # * name<~String> - The name of the disk you want to attach
        # * mount_point<~String> - The filesystem location where this disk will be
        #   mounted.
        # * readonly<~Boolean> - Should the disk be mounted as readonly.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Boolean>
        def attach_disk(vm_id, name, mount_point, readonly = false)
          post('attach_disk', {:vmid => vm_id, :diskname => name, :target => mount_point, :readonly => readonly}, {:response_type => :boolean})
        end

      end

      class Mock

        def attach_disk(vm_id, name, mount_point, readonly = false)
          response = Excon::Response.new

          if vm_id && name && mount_point
            response.status = 200
            response.body = true
          else
            response.status = 404
            raise(Excon::Errors.status_error({:expects => 200}, response))
          end
          response
        end

      end
    end
  end
end
