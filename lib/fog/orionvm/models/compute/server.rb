require 'fog/compute/models/server'

module Fog
  module Compute
    class OrionVM

      class Server < Fog::Compute::Server
        identity  :id,                  :aliases => 'vm_id'

        attribute :hostname
        attribute :disks,               :type => :array
        attribute :created_at,          :aliases => 'creationtime', :type => :time
        # attribute :addresses,           :aliases => 'ips', :type => :array
        attribute :public_ip_address
        attribute :backend_state,       :aliases => 'state'
        attribute :memory,              :aliases => 'ram'
        attribute :vm_type
        attribute :licence

        attr_writer   :private_key, :private_key_path, :public_key, :public_key_path, :username


        VM_STATES = {
          0 => 'stopped',
          1 => 'starting',
          2 => 'running',
          3 => 'stopping',
          4 => 'restarting',
          11 => 'failed-to-boot',
          13 => 'failed-to-shutdown'
        }.freeze

        def initialize(attributes = {})
          super
          merge_attributes({:public_ip_address => attributes['ips'].first}) unless !persisted?
          #prepare_service_value(attributes)
        end

        def state
          VM_STATES[backend_state]
        end

        def ready?
          requires :state
          state.eql?('running')
        end

        def start
          requires :id
          return true if ready? || starting?
          service.deploy(id).body.eql?(true)
        end

        def start!
          start.tap do
            wait_for(120) { ready? }
          end
        end

        def running?
          state.eql?('running')
        end

        def starting?
          state.eql?('starting')
        end

        def stopping?
          state.eql?('stopping')
        end

        def stuck?
          state.eql?("failed-to-boot") || state.eql?("failed-to-shutdown")
        end

        def stop
          requires :id
          return true if stopped? || stopping?
          service.action(id, 'shutdown').body.eql?(true)
        end

        def stop!
          stop.tap do
            wait_for(120) { stopped? }
          end
        end

        def stopped?
          state.eql?('stopped')
        end

        def destroy
          requires :id
          stop!
          service.drop_vm(id).body.eql?(true) rescue Excon::Errors::Forbidden nil
        end

        def destroy_and_cleanup
          requires :id
          stop!

          addresses.each do |address|
            address.server = nil
            address.destroy
          end

          volumes.each do |volume|
            volume.server = nil
            volume.wait_for { ready? }
            volume.destroy
          end

          destroy
        end

        def context
          service.context(id).body
        end

        def context=(new_context = {})
          service.context(id, new_context).body
        end

        def memory=(ram_in_megabytes)
          if !persisted?
            attributes[:memory] = ram_in_megabytes
          elsif stopped? && service.set_ram(id, ram_in_megabytes).body.eql?(true)
            attributes[:memory] = ram_in_megabytes
          end
        end

        def volumes
          service.volumes(:server => self)
        end

        def addresses
          service.addresses(:server => self)
        end

        def networks
          service.networks(:server => self)
        end

        def open_vnc_session(token)
          response = service.create_vnc(id, token).body
          require 'uri'
          uri = URI(service.api_url)
          base = service.api_url
          base["/api"] = ""
          vnc_url = base + "/vnc/?autoconnect=1&host=#{uri.host}&port=443"
          vnc_url += "&password=#{response['auth_token']}&name=#{hostname}"
          vnc_url += "&path=vnc_connect/#{response['port']}&encrypt=true"
          response['url'] = vnc_url
          response
        end

        def save
          raise Fog::Errors::Error.new('Resaving an existing server will cause a failure') if identity

          requires :memory, :hostname
          vm_attributes = service.vm_allocate(hostname, memory, vm_type).body
          merge_attributes(vm_attributes)

          self.reload
          true
        end

        def private_key_path
          @private_key_path ||= Fog.credentials[:private_key_path]
          @private_key_path &&= File.expand_path(@private_key_path)
        end

        def private_key
          @private_key ||= private_key_path && File.read(private_key_path)
        end


        def public_key_path
          @public_key_path ||= Fog.credentials[:public_key_path]
          @public_key_path &&= File.expand_path(@public_key_path)
        end

        def public_key
          @public_key ||= public_key_path && File.read(public_key_path)
        end

        # Assigns private keys etc
        def setup(credentials = {})
          requires :public_ip_address, :username

          unless context['SSH_KEY']
            stop
            wait_for { stopped? }

            self.context = {'SSH_KEY' => public_key}

            start
            wait_for { ready? }
            wait_for { sshable? }
          end

          raise RuntimeError, "Cannot SSH into Instance" unless sshable?

          require 'net/ssh'

          ssh("echo true")
        end

        def username
          @username || 'root'
        end

      end

    end
  end
end

