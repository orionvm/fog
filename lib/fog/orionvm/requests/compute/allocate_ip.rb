module Fog
  module Compute
    class OrionVM
      class Real

        # Allocates an IP Address object
        #
        # ==== Parameters
        # * hostname<~String> - A unqiue name to reference this IP Address object.
        #   It is a good idea to make this the same as the FQHN which will be associated
        #   with it.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>
        #     * ip<~String
        def allocate_ip(hostname, address = nil)
          body = {:friendly => hostname, :address => address}

          if address
            raise ArgumentError, "Address must be a valid IPv4 address" unless
              address =~ /\b(?:\d{1,3}\.){3}\d{1,3}\b/
          end

          post('allocate_ip', body, {:response_type => :hash})
        end
      end

      class Mock

        def allocate_ip(hostname, address=nil)
          response = Excon::Response.new
          ip = { 'down' => 0, 'up' => 0, 'locked' => false, 'vmid' => 0 }
          if address
      	    if !address[/^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/]
              response.status = 400
              Fog::Logger.warning "address is invalid format: #{address}"
              raise(Excon::Errors.status_error({:expects => 200}, response))
            else
              ip_exists = !!self.data[:ips][address]
              if ip_exists
                Fog::Logger.warning "address already in use: #{address}"
                response.status = 412
                raise(Excon::Errors.status_error({:expects => 200}, response))
              else
                ip['ip'] = address
              end
            end
          else
            ip['ip'] = address = Array.new(4){rand(256)}.join('.')
          end

          ip['friendly'] = hostname ? hostname : 'none'
          self.data[:ips][address] = ip          
          
          Fog::Logger.debug "allocated an ip #{ip.inspect}"
          response.status = 200
          response.body = { 'ip' => address }
          response
        end

      end

    end
  end
end
