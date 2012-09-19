Shindo.tests('Fog::Compute::OrionVM | server', ['orion_vm']) do

  # pending if Fog.mocking?

  service = Fog::Compute::OrionVM.new
  options = { :hostname => "test.fog_server_#{Time.now.to_i.to_s}", :memory => 1024 }

  tests("instance lifecycle success") do
    @instance = service.servers.new(options)
    @instance.save
    returns(false) { @instance.new_record? }
    returns(true) { @instance.destroy }
  end

  tests('volumes') do
    @instance = service.servers.create(options)

    tests('create') do
      volume = @instance.volumes.create(size: 50)
      tests('volume exists').returns(true) { volume.ready? }
      #returns(@instance.id) { volume.server_id }
      # puts @instance.inspect
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

    @instance.destroy
  end

  service.volumes.each do |volume|
    volume.destroy if volume.name =~ /test\.fog_server_/
  end

  model_tests(service.servers, options, true) do

  end
#     # @instance.wait_for { ready? }
#
#
#     # tests('#start').succeeds do
#     #   @instance.start
#     #   returns('starting') { @instance.state }
#     # end
#
#     # tests('#reboot("SOFT")').succeeds do
#     #   @instance.reboot('SOFT')
#     #   returns('REBOOT') { @instance.state }
#     # end
#
#     # @instance.wait_for { ready? }
#     # tests('#reboot("HARD")').succeeds do
#     #   @instance.reboot('HARD')
#     #   returns('HARD_REBOOT') { @instance.state }
#     # end
#
#     # @instance.wait_for { ready? }
#     # tests('#rebuild').succeeds do
#     #   @instance.rebuild('5cebb13a-f783-4f8c-8058-c4182c724ccd')
#     #   returns('REBUILD') { @instance.state }
#     # end
#
#     # @instance.wait_for { ready? }
#     # tests('#resize').succeeds do
#     #   @instance.resize(3)
#     #   returns('RESIZE') { @instance.state }
#     # end
#
#     # @instance.wait_for { state == 'VERIFY_RESIZE' }
#     # tests('#confirm_resize').succeeds do
#     #   @instance.confirm_resize
#     # end
#
#     # @instance.wait_for { ready? }
#     # tests('#resize').succeeds do
#     #   @instance.resize(2)
#     #   returns('RESIZE') { @instance.state }
#     # end
#
#     # @instance.wait_for { state == 'VERIFY_RESIZE' }
#     # tests('#revert_resize').succeeds do
#     #   @instance.revert_resize
#     # end
#
#     # @instance.wait_for { ready? }
#     # tests('#change_admin_password').succeeds do
#     #   @instance.change_admin_password('somerandompassword')
#     #   returns('PASSWORD') { @instance.state }
#     #   returns('somerandompassword') { @instance.password }
#     # end
#
#     # @instance.wait_for { ready? }
#   end
end

