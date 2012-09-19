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
          body = {:vmid => vm_id, :disk_name => disk_name}

          post('detach_disk', body, {:response_type => :boolean})
        end

      end

      class Mock
        def detach_disk(vm_id, disk_name)
          response = Excon::Response.new

          if vm_id == 1
            response.status = 200
            response.body = true
          else
            response.status = 403
            raise(Excon::Errors.status_error({:expects => 200}, response))
          end
          response
        end
      end

    end
  end
end
