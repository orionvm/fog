require 'fog/compute/models/server'

module Fog
  module Compute
    class OrionVM

      class Server < Fog::Compute::Server
        identity  :id,                  :aliases => 'vm_id'

        attribute :hostname
        # attribute :volumes,             :aliases => 'disks', :type => :array
        attribute :created_at,          :aliases => 'creationtime', :type => :time
        # attribute :addresses,           :aliases => 'ips', :type => :array
        attribute :public_ip_address
        attribute :backend_state,       :aliases => 'state'
        attribute :memory,              :aliases => 'ram'
        attribute :vm_type
        attribute :licence

        VM_STATES = {
          0 => 'stopped',
          1 => 'starting',
          2 => 'running',
          3 => 'stopping',
          4 => 'rebooting',
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
          return true if ready?
          connection.deploy(id).body.eql?(true)
          wait_for(120) { ready? } if wait.eql?(true)
        end

        def running?
          state.eql?('running')
        end

        def stop(wait = false)
          requires :id
          return true if stopped?

          connection.action(id, 'shutdown').body.eql?(true)
          wait_for(120) { stopped? } if wait.eql?(true)
        end

        def stopped?
          state.eql?('stopped')
        end

        def destroy
          requires :id
          connection.drop_vm(id).body.eql?(true)
        end

        def memory=(ram_in_megabytes)
          if new_record?
            attributes[:memory] = ram_in_megabytes
          elsif stopped? && connection.set_ram(id, ram_in_megabytes).body.eql?(true)
            attributes[:memory] = ram_in_megabytes
          end
        end

        def volumes
          connection.volumes.all(:name => hostname)
        end

        def addresses
          connection.addresses.all(:server => self)
        end
#
#         remove_method :addresses
#         def addresses
#           # connection.addresses.all(:vmid => id)
#           connection.addresses.all(:server => self)
#         end

        def save
          raise Fog::Errors::Error.new('Resaving an existing server will cause a failure') if identity

          requires :memory, :hostname

          vm_attributes = connection.vm_allocate(hostname, memory).body
          merge_attributes(vm_attributes)

          self.reload

          # addresses.create(:hostname => hostname)

          # connection.allocate_ip
          # connection.deploy_disk(hostname, 'ubuntu-lucid', 50)
          # connection.attach_disk()

          # setup

          true
        end

        # Assigns private keys etc
        def setup(credentials = {})
          requires :public_ip_address, :username

        end

        def username
          @username ||= 'root'
        end


      end

    end
  end
end

