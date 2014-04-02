module Fog
  module Compute
    class OrionVM
      class Real

        # Allocates a new VM.
        #
        # ==== Parameters
        # * hostname<~String> - The name of the vm - must be unqiue
        # * ram<~Integer> - The amount of RAM to give it.
        #   Must be entered in whole units, in Gigabytes.
        #   The minimum size is: 0.5GB
        #   The maximum size is: 16GB
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>
        #     * vm_id<~Integer>
        def vm_allocate(hostname, ram_in_megabytes = 1024, vm_type = 'HVM', options = nil)
          options ||= {}
          raise ArgumentError, "Minimum RAM is 512MB" if ram_in_megabytes < 512
          raise ArgumentError, "Maximum RAM size is 16GB" if ram_in_megabytes > 16 * 1024
          raise ArgumentError, "Hostname must be provided" if hostname.empty?

          body = {:hostname => hostname, :ram => "#{ram_in_megabytes}M", vm_type: vm_type}

          response = post('vm_allocate', body, {:response_type => :integer}.merge(options))
          response.body = {'vm_id' => response.body}
          response
        end

      end

      class Mock
        def vm_allocate(hostname, ram_in_megabytes = 1024, vm_type = 'HVM', options = nil)
          raise ArgumentError, "Minimum RAM is 512MB" if ram_in_megabytes < 512
          raise ArgumentError, "Maximum RAM size is 16GB" if ram_in_megabytes > 16 * 1024
          raise ArgumentError, "Hostname must be provided" if hostname.empty?
          
          response = Excon::Response.new
          instances = self.data[:instances]
          test = instances.select {|id, vm| vm['hostname'] == hostname}
          if test.count > 0
            response.status = 412
            raise(Excon::Errors.status_error({:expects => 200}, response))
          end
          
          id = self.data[:instances].count + 1
          vm = {
            'disks' => [],
            'hostname' => hostname,
            'ram' => ram_in_megabytes,
            'ips' => [],
            'license' => nil,
            'state' => 0,
            'vm_id' => id,
            'vm_type' => vm_type
          }
          self.data[:instances][id] = vm
          
          STDERR.puts 'allocated a vm'
          STDERR.puts vm
          response.status = 200
          response.body = { 'vm_id' => id }
          response
        end
      end
    end
  end
end
