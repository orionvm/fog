Shindo.tests('Fog::Compute[:orion_vm] | action requests', ['orion_vm']) do

  @datacenters_format = OrionVM::Compute::Formats::BASIC.merge({
    'DATA' => [{ 
      'DATACENTERID'  => Integer,
      'LOCATION'      => String
    }]
  })

  tests('success') do

    tests('#action - shutdown').formats(@datacenters_format) do
      Fog::Compute[:orion_vm].action('shutdown').body
    end

  end

end

