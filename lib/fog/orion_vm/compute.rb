require 'fog/orion_vm'
require 'fog/compute'

module Fog
  module Compute
    class OrionVM < Fog::Service

      requires :orion_vm_password, :orion_vm_username
      secrets    :orion_vm_username, :orion_vm_password
      recognizes :orion_vm_api_url, :persistent

      model_path 'fog/orion_vm/models/compute'
      request_path 'fog/orion_vm/requests/compute'

      model       :server
      collection  :servers

      model       :network
      collection  :networks

      model       :volume
      collection  :volumes

      model       :address
      collection  :addresses

      # Account requests
      request :create_user
      request :user_details

      # IP Address requests
      request :ip_pool
      request :allocate_ip
      request :attach_ip
      request :drop_ip
      request :detach_ip

      # VM requests
      request :vm_pool
      request :vm_allocate
      request :drop_vm
      request :deploy
      request :context
      request :action
      request :set_ram
      request :create_vnc

      # VLan requests
      request :vlan_pool
      request :allocate_vlan
      request :drop_vlan
      request :attach_vlan
      request :detach_vlan

      # Disk requests
      request :disk_pool
      request :deploy_disk
      request :attach_disk
      request :create_disk
      request :drop_disk
      request :detach_disk

      class Mock
        def self.data
          @data ||= Hash.new do |hash, key|
            hash[key] = {}
          end
        end

        def self.reset
          @data = nil
        end


        def initialize(options)
          require 'multi_json'
          @api_url = options[:orion_vm_api_url] || Fog.credentials[:orion_vm_api_url] || Fog::OrionVM::API_V1_URL
          @orion_vm_username = options[:orion_vm_username] || Fog.credentials[:orion_vm_username]
          @orion_vm_password = options[:orion_vm_password] || Fog.credentials[:orion_vm_password]
        end

        def request(*args)
          Fog::Mock.not_implemented
        end
      end

      class Real
        attr_reader :connection, :api_url

        def initialize(options)
          require 'multi_json'
          @api_url = options[:orion_vm_api_url] || Fog.credentials[:orion_vm_api_url] || Fog::OrionVM::API_V1_URL
          @orion_vm_username = options[:orion_vm_username] || Fog.credentials[:orion_vm_username]
          @orion_vm_password = options[:orion_vm_password] || Fog.credentials[:orion_vm_password]
          @connection = Fog::Connection.new(@api_url, @persistent)
        end

        def post(path, body, options = {})
          options = {
            :method => 'POST',
            :response_type => :boolean,
            :query => body,
            :idempotent => true
          }.update(options || {})

          request(path, options)
        end

        def get(path, options = {})
          options = {
            :response_type => :hash
          }.update(options || {})

          request(path, options)
        end

        def request(command, options = nil)
          options ||= {}

          uri = URI.parse(api_url)

          options = {
            :expects => [200],
            :method => 'GET',
            :path => [uri.path, command].join('/'),
            :response_type => Hash
          }.merge(options)

          options[:query]   ||= {}
          options[:headers] ||= {}

          case options[:method]
          when 'DELETE', 'GET', 'HEAD'
            options[:headers]['Accept'] = 'application/json'
          when 'POST', 'PUT'
            options[:headers]['Content-Type'] = 'application/json'
          end

          options[:headers]['Authorization'] = "Basic #{basic_auth}"

          begin
            response = @connection.request(options)
          rescue Excon::Errors::HTTPStatusError => error
            raise error
            # raise case error
            # when Excon::Errors::NotFound
            #   Fog::Compute::OrionVM::NotFound.slurp(error)
            # else
            #   error
            # end
          end

          # We need to tell the request how to handle the response because
          # OrionVM doesn't always return true JSON.
          unless response.body.empty?
            response.body = case options[:response_type].to_s.downcase.to_sym
            when :hash, :array
              MultiJson.decode(response.body)
            when :integer
              response.body.chomp.to_i
            when :boolean
              response.body.chomp.downcase.eql?('true')
            when :string
              response.body.chomp
            else
              MultiJson.decode(response.body)
            end
          end

          response
        end

        def reload
          @connection.reset
        end

        private

        def parse_date(attribute, object)
          object[attribute.to_s] = Time.at(object[attribute.to_s])
        rescue
          object[attribute.to_s] = object[attribute.to_s]
        end

        def basic_auth
          Base64.strict_encode64([@orion_vm_username, @orion_vm_password].join(':')).chomp
        end
      end

    end
  end
end
