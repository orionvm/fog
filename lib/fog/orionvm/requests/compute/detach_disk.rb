module Fog
  module Compute
    class OrionVM
      class Real

        # Detaches a disk from a VM
        #
        # ==== Parameters
        # * vm_id<~Integer> - The ID of the VM to detach a disk from
        # * disk_name<~String> - The name of the disk to detach
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Boolean>
        def detach_disk(vm_id, disk_name)
          body = {:vmid => vm_id, :diskname => disk_name}

          post('detach_disk', body, {:response_type => :boolean})
        end

      end

      class Mock
        def detach_disk(vm_id, disk_name)
          response = Excon::Response.new
          response.body = true
          
          name = disk_name
          vm_id = vm_id.to_i
          
          vm = self.data[:instances][vm_id]
          disk = self.data[:disks][name]
  
          if !disk
            response.body = "disk not found with name #{name}"
          elsif !disk['locked'] || !disk['vm']
            response.body = 'disk is not attached'
          end
          
          if !vm
            response.body = "no instance found with name id #{vm_id}"
          elsif vm['state'] != 0
            response.body = "instance not in appropriate state to detach a disk #{vm['state']}"
          end
          
          if response.body == true
            disk['locked'] = false
            disk['vm'] = nil
            
            vm['disks'].delete_if { |d| d['name'] == disk_name}
            
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
