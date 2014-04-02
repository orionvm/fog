module Fog
  module Compute
    class OrionVM
      class Real

        # Drops (deletes) an IP Address.
        #
        # ==== Parameters
        # * ip_address<~String> - The IP address to drop.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Boolean>
        def drop_ip(ip_address, options = nil)
          options ||= {}
          post('drop_ip', {:ip => ip_address}, {:response_type => :boolean}.merge(options))
        end

      end

      class Mock

        def drop_ip(ip_address, options = nil)
          response = Excon::Response.new
          
          if ip_address
            ip = self.data[:ips][ip_address]
            if ip && !ip['locked']
              self.data[:ips].delete(ip_address)
              response.status = 200
              response.body = true
              return response
            end
          end

          puts 'invalid request to drop ip', ip
          response.status = 400
          raise(Excon::Errors.status_error({:expects => 200}, response))

        end

      end
    end
  end
end
