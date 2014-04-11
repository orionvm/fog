module Fog
  module Compute
    class OrionVM
      class Real

        def set_ram(vm_id, ram_in_megabytes = 1024, options = nil)
          options ||= {}
          raise ArgumentError, "Minimum RAM is 512MB" if ram_in_megabytes < 512
          raise ArgumentError, "Maximum RAM size is 16GB" if ram_in_megabytes > 16 * 1024

          body = {:vmid => vm_id, :ram => "#{ram_in_megabytes}M"}

          post('set_ram', body, {:response_type => :boolean}.merge(options))
        end

      end

      class Mock
        def set_ram(vm_id, ram_in_megabytes = 1024, options = nil)
          response = Excon::Response.new
          vm_id = vm_id.to_i
          
          if ram_in_megabytes < 512 || ram_in_megabytes > 65535
            response.status = 400
            response.body = false
            Fog::Logger.warning 'invalid RAM amount'
            raise(Excon::Errors.status_error({:expects => 200}, response))
          end
          
          vm = self.data[:instances][vm_id]
          if !vm
            response.status = 400
            response.body = false
            Fog::Logger.warning 'vmid not found: #{vm_id}'
            raise(Excon::Errors.status_error({:expects => 200}, response))
          else
            vm['ram'] = ram_in_megabytes
            response.status = 200
            response.body = true
          end
          response
        end
      end
    end
  end
end

