Shindo.tests('Fog::Compute::OrionVM | server', ['orion_vm']) do

  service = Fog::Compute::OrionVM.new
  options = { :hostname => "test.fog_server_#{Time.now.to_i.to_s}", :memory => 1024 }

  tests('volumes') do
    @instance = service.servers.create(options)

    tests('create') do
      volume = @instance.volumes.create(size: 50)
      tests('volume exists').returns(true) { volume.ready? }
      @instance.reload
      returns(1) { @instance.disks.size }
      returns(1) { @instance.volumes.size }
    end

    tests('removing a volume') do
      tests("volume can be loaded").returns(true) { !!@instance.volumes.first }
      tests("it removes a volume").returns(true) do
        volume = @instance.volumes.first
        volume.detach
      end
    end

    tests('destroying').returns(true) do
      volume = @instance.volumes.first

      volume.wait_for { volume.ready? }
      volume.destroy
    end

    @instance.destroy
  end
end
