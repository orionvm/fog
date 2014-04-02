module Fog
  module Compute
    class OrionVM
      class Real

        # Creates a new blank disk.
        #
        # ==== Parameters
        # * name<~String> - The name of the disk - must be unqiue
        # * size_in_gigabytes<~Integer> - The physical size to allocate for
        #   this disk. Must be entered in whole units, in Gigabytes.
        #   The minimum size is: 20GB
        #   The maximum size is: 2048GB
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Boolean>
        def create_disk(name, size_in_gigabytes = 20)
          raise ArgumentError, "Minimum disk size is 20GB" if size_in_gigabytes < 20.0
          raise ArgumentError, "Maximum disk size is 2048GB" if size_in_gigabytes > 2048.0

          body = {:diskname => name, :size => "#{size_in_gigabytes}G"}

          post('create_disk', body, {:response_type => :boolean})
        end

      end

      class Mock
        def create_disk(name = nil, size_in_gigabytes = 20)
          response = Excon::Response.new
          
          size = size_in_gigabytes.to_i
          raise ArgumentError, "Minimum disk size is 20GB" if size < 20.0
          raise ArgumentError, "Maximum disk size is 2048GB" if size > 2048.0
          puts 'DISKS!'
          puts self.data[:disks]
          disk = self.data[:disks][name]
          if !!disk || !name
            response.status = 400
            response.body = 'diskname is invalid'
            if !!disk
              STDERR.puts "disk already exists #{name}"
            else
              STDERR.puts 'disk name is required'
            end
            raise(Excon::Errors.status_error({:expects => 200}, response))
          end
                
          response.status = 200
          self.data[:disks][name] = { 'vm' => nil, 'image' => '', 'locked' => false, 'name' => name, 'size' => size}
          response.body = true
          
          response
        end
      end
    end
  end
end
