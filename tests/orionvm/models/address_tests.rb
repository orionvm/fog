Shindo.tests('Fog::Compute::OrionVM | addresses', ['orionvm']) do

  service = Fog::Compute::OrionVM.new
  #service = Fog::Compute.new({:provider => :orionvm})
  server_options = { :hostname => "test.fog_server_#{Time.now.to_i.to_s}", :memory => 1024 }
  address_options = { :hostname => "test.fog_address_#{Time.now.to_i.to_s}" }

  def cleanup
    puts "running after test logic"
    if @instance
      @instance.destroy
      @instance = nil
    end
    if @address
      @address.destroy
      @address = nil
    end
  end

  tests("addresses1") do
    
    after do
      cleanup
    end
    
    tests('it does not have a server attached').returns(false) do
      @address = service.addresses.create(address_options)
      !!@address.server
    end

    tests('attaching a server').returns(true) do
      @instance = service.servers.create(server_options)
      puts 'instance created: ', @instance
      @address = service.addresses.create(address_options)
      temp = @address.server=(@instance)
      !!@address.server
    end

    # tests('counting attached servers').returns(1) do
    #   instance = service.servers.create(server_options)
    #   address = service.addresses.create(server_options)
    #   address.server = instance
    #   instance.addresses.size
    # end

    tests('no servers attached').returns(0) do
      @instance = service.servers.create(server_options.merge(:hostname => 'another.server'))
      @instance.addresses.size
    end

  end
  
  tests("addresses2") do
    
    tests('attaching an address') do
      @instance = service.servers.create(server_options)
      @address = service.addresses.create(address_options)
      @address.wait_for { ready? }
      returns(nil) { @address.server }
      puts 'heres the server', @instance
      attach = (@address.server = @instance)
      returns(true) { attach.kind_of? Fog::Compute::OrionVM::Server }
      returns(@instance.id) { @address.server_id }
      returns(1) { @instance.addresses.size }
      
      cleanup
    end

    tests('creating an address') do
      @instance = service.servers.create({ :hostname => 'test_name_matches', :memory => 512})
      @address = @instance.addresses.create({ :hostname => 'test_name_matches'})
      returns(1) { @instance.addresses.size }
      returns(@address.id) { @instance.addresses.first.id }
      returns(@address.hostname) { @instance.hostname }
      
      cleanup
    end

    tests('removing an address') do
      server = service.servers.create(server_options)
      puts server.inspect
      ip = service.addresses.create(address_options)
      puts ip.inspect
      ip.server = server
      returns(server.id) { ip.server.id }
      returns(nil) { ip.disassociate }
      returns(nil) { ip.server }
      returns(true) { ip.destroy }
      server.destroy
    end
  end

  

  tests('allocation') do
    tests("can allocate with custom address").returns(true) do
      !!service.addresses.create(:address => '123.234.123.234', :hostname => 'test.address')
    end
  end

  tests('gets an address').returns(true) do
    !!service.addresses.get('123.234.123.234')
  end

  tests('destroy') do
    tests('can destroy address').returns(true) do
      service.addresses.get('123.234.123.234').destroy
    end
  end

end
