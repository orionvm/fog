Shindo.tests("Fog::Compute[:orion_vm] | address", ['orion_vm']) do

  params = {hostname: 'test.instance'}

  model_tests(Fog::Compute[:orion_vm].addresses, params, true) do

    @server = Fog::Compute[:orion_vm].servers.create(hostname: 'test.instance', memory: 1024)
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

  model_tests(Fog::Compute[:orion_vm].addresses, params, true)
end

