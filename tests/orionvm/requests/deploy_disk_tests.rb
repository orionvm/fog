Shindo.tests('Fog::Compute[:orionvm] | deploy disk', ['orionvm']) do

  tests('success') do

    tests('#deploy_disk').returns(true) do
      name = 'test'
      template = 'ubuntu-precise'
      size = 20
      Fog::Compute[:orionvm].deploy_disk(name, template, size).body
    end

  end

end


