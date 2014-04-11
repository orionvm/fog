Shindo.tests('Fog::Compute::OrionVM | addresses', ['orionvm']) do

  service = Fog::Compute::OrionVM.new
  #service = Fog::Compute.new({:provider => :orionvm})
  server_options = { :hostname => "test.fog_server_#{Time.now.to_i.to_s}", :memory => 1024 }
  address_options = { :hostname => "test.fog_address_#{Time.now.to_i.to_s}" }

  def cleanup
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
      ip = service.addresses.create(address_options)
      ip.server = server
      returns(server.id) { ip.server.id }
      returns(nil) { ip.disassociate }
      returns(nil) { ip.server }
      returns(true) { ip.destroy }
      server.destroy
    end
  end

  address = '123.234.123.234'

  tests('allocation') do
    tests("can allocate with custom address") do
      if Fog.mocking?
        tests('mock version').returns(true) do 
          !!service.addresses.create(:address => address, :hostname => 'test.address')
        end
      else
        tests('non mock version').raises(Excon::Errors::Conflict) do
          service.addresses.create(:address => address, :hostname => 'test.address')
        end
        tests('not mocked, get ip without address').returns(true) do 
          result = service.addresses.create(:hostname => 'test.address')
          address = result.id
          !!result
        end
      end
    end
  end

  tests('gets an address').returns(true) do
    !!service.addresses.get(address)
  end

  tests('destroy') do
    tests('can destroy address').returns(true) do
      service.addresses.get(address).destroy
    end
  end

end
