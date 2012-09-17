module Fog
  module Compute
    class OrionVM
      class Real

        # Deploys (starts) a VM
        #
        # ==== Parameters
        # * filters<~Hash> - A key value pair to filer the results by.
        # * options<~Hash> - Options to be passed to the request.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>
        def vm_pool(filters = nil, options = nil)
          filters ||= {}
          options ||= {}

          response = get('vm_pool', options)
          response.body.map {|object| parse_date(:creationtime, object); object }

          unless filters.empty? || response.body.empty?
            filters.each do |filter, requirement|
              if response.body.all? { |server| server.keys.include?(filter.to_s) }
                response.body = response.body.select { |vm| vm[filter.to_s] == requirement }
              end
            end
          end

          response
        end

      end

      class Mock
        def vm_pool(filters = nil, options = nil)
          filters ||= {}
          options ||= {}

          response = Excon::Response.new
          response.status = 200
          response.body = [{
            "hostname"=> 'example.instance.com',
            "vm_type"=> 'paravirt',
            "disks"=>[
              {"readonly"=> false,
                "name"=> 'example.instance.com',
                "image"=> 'ubuntu-lucid',
                "target"=> 'xvda1'
              }
            ],
            "creationtime"=> Time.parse("1/1/2012"),
            "ips"=>['123.234.123.234'],
            "state"=> 2,
            "ram"=> 2048,
            "licence"=> nil,
            "vm_id"=> 1
          }]

          unless filters.empty? || response.body.empty?
            filters.each do |filter, requirement|
              if response.body.all? { |server| server.keys.include?(filter.to_s) }
                response.body = response.body.select { |vm| vm[filter.to_s] == requirement }
              end
            end
          end

          response
        end
      end

    end
  end
end
