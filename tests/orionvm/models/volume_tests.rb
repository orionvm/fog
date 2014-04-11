Shindo.tests('Fog::Compute::OrionVM | server', ['orion_vm']) do

  service = Fog::Compute::OrionVM.new
  

  tests('volumes') do
    
    options = { :hostname => "test.fog_server2_#{Time.now.to_i.to_s}", :memory => 1024 }
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
    
    tests('create, attach, detach, destroy') do
      volume = service.volumes.create(size: 30, image: 'ubuntu-precise', name: 'fogtest')
      tests("volume is ready").returns(true) { volume.ready? }
      tests("volume starts of detached").returns(nil) { volume.server }

      volume.server = @instance
      tests("volume is attached").returns(@instance.id) { volume.server.id }
      
      volume.server = nil
      @instance.reload
      tests("volume is detached").returns(0) { @instance.volumes.count }
      volume.destroy
      tests("volume is destroyed").returns(nil) { service.volumes.get 'fogtest' }
      
    end

    @instance.destroy
  end
end
