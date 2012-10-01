Shindo.tests('Fog::Compute[:orion_vm] | deploy disk', ['orion_vm']) do

  # @datacenters_format = OrionVM::Compute::Formats::BASIC.merge({
  #   'DATA' => [{ 
  #     'DATACENTERID'  => Integer,
  #     'LOCATION'      => String
  #   }]
  # })

  tests('success') do

    tests('#deploy_disk') do
      Fog::Compute[:orion_vm].action('shutdown').body.eql?(true)
    end

  end

end


