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
        #   The maximum size is: 400GB
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Boolean>
        def create_disk(name, size_in_gigabytes = 20)
          raise ArgumentError, "Minimum disk size is 20GB" if size_in_gigabytes < 20.0
          raise ArgumentError, "Maximum disk size is 400GB" if size_in_gigabytes > 400.0

          body = {:diskname => name, :size => "#{size_in_gigabytes}G"}

          post('create_disk', body, {:response_type => :boolean})
        end

      end

      class Mock
        def create_disk(name = nil, size_in_gigabytes = 20)
          response = Excon::Response.new

          if name && size_in_gigabytes
            response.status = 200
            response.body = {:name => name, :size => size_in_gigabytes, :locked => false}
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