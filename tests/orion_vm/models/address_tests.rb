Shindo.tests('Fog::Compute::OrionVM | addresses', ['orion_vm']) do

  service = Fog::Compute::OrionVM.new
  options = { :hostname => "test.fog_server_#{Time.now.to_i.to_s}", :memory => 1024 }

  tests("addresses") do

    tests('attaching an address') do
      @instance = service.servers.create(options)
      address = service.addresses.create(options)
      address.wait_for { address.ready? }
      returns(nil) { address.server }
      address.server = @instance
      returns(@instance.id) { address.server_id }
      returns(1) { @instance.addresses.size }
      @instance.destroy
      address.destroy
    end

    tests('creating an address') do
      @instance = service.servers.create(options)
      address = @instance.addresses.create(options)
      returns(1) { @instance.addresses.size }
      returns(address.id) { @instance.addresses.first.id }
      returns(address.hostname) { @instance.hostname }

      @instance.destroy
      address.destroy
    end

    tests('removing an address') do
      @instance = service.servers.create(options)
      address = service.addresses.create(options)
      address.server = @instance
      returns(@instance.id) { address.server.id }
      returns(nil) { address.disassociate }
      returns(nil) { address.server }
      returns(true) { address.destroy }
      @instance.destroy
    end
  end

end
