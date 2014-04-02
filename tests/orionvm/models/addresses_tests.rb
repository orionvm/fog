Shindo.tests("Fog::Compute[:orion_vm] | address", ['orionvm']) do

  params = {hostname: 'test.instance'}
  service = Fog::Compute::OrionVM.new
  
  model_tests(service.addresses, params, true) do

    @server = service.servers.create(hostname: 'test.instance', memory: 1024)
    @server.start!
    @server.wait_for { ready? }

    tests('#server=').succeeds do
      @instance.server = @server
    end

    tests('#server') do
      test(' == @server') do
        @server.reload
        @instance.server.public_ip_address == @instance.id
      end
    end

    @server.destroy
  end

  model_tests(service.addresses, params, true)
end

