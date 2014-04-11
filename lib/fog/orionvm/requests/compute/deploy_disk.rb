module Fog
  module Compute
    class OrionVM
      class Real

        # Creates a new disk from an existing image, which can either be one
        # of the official OrionVM base images or an existing disk under your
        # account.
        #
        # ==== Parameters
        # * name<~String> - The name of the disk - must be unqiue
        # * template<~String> - The name of an existing disk to base this
        #   disk on.
        #   Base images are: debian-lenny, ubuntu-lucid, centos
        # * size_in_gigabytes<~Integer> - The physical size to allocate for
        #   this disk. Must be entered in whole units, in Gigabytes.
        #   The minimum size is: 20GB
        #   The maximum size is: 400GB
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Boolean>
        def deploy_disk(name, template, size_in_gigabytes = 20)
          raise ArgumentError, "Minimum disk size is 20GB" if size_in_gigabytes < 20.0
          raise ArgumentError, "Maximum disk size is 400GB" if size_in_gigabytes > 400.0

          body = {:diskname => name, :size => "#{size_in_gigabytes}G", :image => template}

          post('deploy_disk', body, {:response_type => :boolean})
        end

      end

      class Mock
        def deploy_disk(name, template, size_in_gigabytes = 20)
          response = Excon::Response.new
          raise ArgumentError, "Minimum disk size is 20GB" if size_in_gigabytes < 20.0
          raise ArgumentError, "Maximum disk size is 400GB" if size_in_gigabytes > 400.0
          
          disk = self.data[:disks][name]
          if !!disk || !name
            response.status = 400
            response.body = 'diskname is invalid'
            if !!disk
              Fog::Logger.warning "disk already exists #{name}"
            else
              Fog::Logger.warning 'disk name is required'
            end
            raise(Excon::Errors.status_error({:expects => 200}, response))
          end
                
          response.status = 200
          response.body = false
          if template && template.length > 0
            response.body = true
            self.data[:disks][name] = { 'vm' => nil, 'image' => template, 'locked' => false, 'name' => name, 'size' => size_in_gigabytes}
          end
          
          response
        end
      end

    end
  end
end
