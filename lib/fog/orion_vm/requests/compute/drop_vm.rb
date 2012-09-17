module Fog
  module Compute
    class OrionVM
      class Real
        
        def drop_vm(vm_id, options = nil)
          options ||= {}
          post('drop_vm', {:vmid => vm_id}, {:response_type => :boolean}.merge(options))
        end
        
      end
    end
  end
end
