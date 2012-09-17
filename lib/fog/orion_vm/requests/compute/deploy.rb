module Fog
  module Compute
    class OrionVM
      class Real
        
        # Deploys (starts) a VM
        #
        # ==== Parameters
        # * vm_id<~Integer> - The ID of the VM you want to start.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Boolean>
        def deploy(vm_id, options = nil)
          options ||= {}
          post('deploy', {:vmid => vm_id}, options)
        end
        
        # VM States:
        # Normal States
        # 0 -> Not running
        # 2 -> Running
        # 
        # Transition States
        # 1 -> Being booted
        # 3 -> Shutting down
        # 4 -> Being rebooted
        # 
        # Error States
        # 11 -> Failed to boot
        # 13 -> Failed to shut down
                
      end
    end
  end
end
