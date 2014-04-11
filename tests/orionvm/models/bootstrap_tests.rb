Shindo.tests('Fog::Compute::OrionVM | server bootstrapping', ['orion_vm']) do

  service = Fog::Compute::OrionVM.new
  options = { :hostname => "test.fog_server_#{Time.now.to_i.to_s}", :memory => 1024 }

  tests("bootstrap") do
    @instance = service.servers.bootstrap(options)
    returns(true) { @instance.ready? }

    tests("can shutdown").returns(true) do
      @instance.stop!
    end

    tests('can destroy and cleanup').returns(true) do
      volume_name = @instance.volumes.first.name
      address_id = @instance.addresses.first.id
      instance_id = @instance.id

      @instance.destroy_and_cleanup

      tests('volume should be nil').returns(nil) { service.volumes.get(volume_name) }
      tests('address should be nil').returns(nil) { service.addresses.get(address_id) }
      tests('server should be nil').returns(nil) { service.servers.get(instance_id) }
    end
  end


end