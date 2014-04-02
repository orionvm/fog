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
          response.body = true
          
          vm_id = vm_id.to_i
          
          vm = self.data[:instances][vm_id]
          disk = self.data[:disks][name]
  
          if !disk
            response.body = "disk not found with name #{name}"
          elsif disk['locked']
            response.body = "disk is locked #{name}"
          end
          
          if !vm
            response.body = "no instance found with name id #{vm_id}"
          elsif vm['state'] != 0
            response.body = "instance not in appropriate state to attach a disk #{vm['state']}"
          end
          
          if !mount_point || mount_point.length == 0
            response.body = "invalid mount point #{mount_point}"
          end
  
          
          if response.body == true
            disk['locked'] = true
            disk['vm'] = vm_id
            
            reldisk = disk.clone
            reldisk.delete('vm')
            vm['disks'].push(reldisk)
            
            response.status = 200
            return response
          else
            response.status = 400
            raise(Excon::Errors.status_error({:expects => 200}, response))
          end
        end

      end
    end
  end
end
