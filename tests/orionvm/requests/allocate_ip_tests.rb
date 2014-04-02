Shindo.tests('Fog::Compute::OrionVM | allocate_ip', ['orionvm']) do
  pending unless Fog.mocking?

  service = Fog::Compute[:orionvm]
  options = {}

  tests("allocate IP").returns(0) do
    pending unless Fog.mocking?
    ip = service.allocate_ip("example.com").body['ip']
    ip =~ /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}$/
  end

  tests("allocate IP with custom address").returns("49.156.17.49") do
    service.allocate_ip("example.com", "49.156.17.49").body['ip']
  end

  tests("fails when allocating an address which isn't available").raises(Excon::Errors::HTTPStatusError) do
    service.allocate_ip("example.com", "49.156.17.49").body['ip']
  end
end
