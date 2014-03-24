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
          response.body.map {|object| parse_vlans(object); object }

          unless filters.empty? || response.body.empty?
            filters.each do |filter, requirement|
              if response.body.all? { |server| server.keys.include?(filter.to_s) }
                response.body = response.body.select do |vm|
                  Array(requirement).include?(vm[filter.to_s])
                end
              end
            end
          end

          response
        end

        def parse_vlans(object)
          object['vlans'] = object['vlans'].map { |v| {'id' => v} }
        rescue
          object
        end

      end

      class Mock
        def vm_pool(filters = nil, options = nil)
          filters ||= {}
          options ||= {}

          query_hostname = filters[:hostname]

          response = Excon::Response.new
          response.status = 200
          response.body = [{
            "hostname"=> (query_hostname || 'example.instance.com'),
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
            "vm_id"=> 1337
          },
          {
            "hostname"=> 'another.instance',
            "vm_type"=> 'paravirt',
            "disks"=>[
              {"readonly"=> false,
                "name"=> 'example.instance.com',
                "image"=> 'ubuntu-lucid',
                "target"=> 'xvda1'
              }
            ],
            "creationtime"=> Time.parse("1/1/2012"),
            "ips"=>[],
            "state"=> 2,
            "ram"=> 2048,
            "licence"=> nil,
            "vm_id"=> 1338
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
