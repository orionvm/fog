Shindo.tests('Fog::Compute::OrionVM | allocate_ip', ['orion_vm']) do
  pending unless Fog.mocking?

  service = Fog::Compute[:orion_vm]
  options = {}

  tests("allocate IP").returns("123.234.123.234") do
    pending unless Fog.mocking?
    service.allocate_ip("example.com").body['ip']
  end

  tests("allocate IP with custom address").returns("49.156.17.49") do
    service.allocate_ip("example.com", "49.156.17.49").body['ip']
  end

  tests("fails when allocating an address which isn't available").raises(Excon::Errors::HTTPStatusError) do
    service.allocate_ip("example.com", "123.234.123.231").body['ip']
  end
end
