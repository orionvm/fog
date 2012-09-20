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
          merge_attributes({:public_ip_address => attributes['ips'].first}) unless new_record?
        end

        def state
          VM_STATES[backend_state]
        end

        def ready?
          requires :state
          state.eql?('running')
        end

        def start(wait = false)
          requires :id
          return true if ready? || starting?
          result = connection.deploy(id).body.eql?(true)
          wait_for(120) { ready? } if wait.eql?(true)
          result
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

        def stop(wait = false)
          requires :id
          return true if stopped? || stopping?

          result = connection.action(id, 'shutdown').body.eql?(true)
          wait_for(120) { stopped? } if wait.eql?(true)
          result
        end

        def stopped?
          state.eql?('stopped')
        end

        def destroy
          requires :id
          connection.drop_vm(id).body.eql?(true)
        rescue Excon::Errors::Forbidden
          nil
        end

        def destroy_and_cleanup
          requires :id
          stop(true)

          addresses.each do |address|
            address.server = nil
            address.destroy
          end

          volumes.each do |volume|
            puts "Destring volume: #{volume.id}"
            volume.server = nil
            volume.wait_for { ready? }
            volume.destroy
          end

          destroy
        end

        def context
          connection.context(id).body
        end

        def context=(new_context = {})
          connection.context(id, new_context).body
        end

        def memory=(ram_in_megabytes)
          if new_record?
            attributes[:memory] = ram_in_megabytes
          elsif stopped? && connection.set_ram(id, ram_in_megabytes).body.eql?(true)
            attributes[:memory] = ram_in_megabytes
          end
        end

        def volumes
          connection.volumes(:server => self)
        end

        def addresses
          connection.addresses(:server => self)
        end

        def save
          raise Fog::Errors::Error.new('Resaving an existing server will cause a failure') if identity

          requires :memory, :hostname

          vm_attributes = connection.vm_allocate(hostname, memory).body
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

          commands = [
            %{echo "#{Fog::JSON.encode(Fog::JSON.sanitize(attributes))}" >> ~/attributes.json}
          ]

          ssh(commands)
        end

        def username
          @username || 'root'
        end

      end

    end
  end
end

