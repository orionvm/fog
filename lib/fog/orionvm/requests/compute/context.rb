module Fog
  module Compute
    class OrionVM
      class Real

        # Accesses the VM's key/value context store.
        # If no arguments are given it will return the current value,
        # otherwise it will set the value based on each key value pair
        # given in new_context.
        #
        # ==== Parameters
        # * vm_id<~Integer> - VM ID
        # * new_context<~Hash> - Key value pairs to set. (Optional)
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>
        def context(vm_id, new_context = {})
          unless new_context.empty?
            new_context.each do |key, value|
              body = {:vmid => vm_id, :key => key, :value => value}
              post('context', body, {:response_type => :boolean})
            end
          end

          get('context', {:query => {:vmid => vm_id}, :response_type => :hash})
        end

      end

      class Mock
        def context(vm_id, new_context = {})
          response = Excon::Response.new

          vm = self.data[:instances][vm_id]
          if !vm
            response.status = 400
            Fog::Logger.warning 'vm not found with id #{vm_id}'
            raise(Excon::Errors.status_error({:expects => 200}, response))
          end

          context = self.data[:context][vm_id] || {}
          context.merge!(new_context)
          self.data[:context][vm_id] = context
          
          response.status = 200
          response.body = context
          response
        end
      end

    end
  end
end