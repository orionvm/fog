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
        def vm_allocate(vm_id, ram_in_megabytes = 1024, options = nil)
          response = Excon::Response.new

          if vm_id.to_i == 1 && ram_in_megabytes >= 512
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

