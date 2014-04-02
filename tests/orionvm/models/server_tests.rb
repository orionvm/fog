Shindo.tests('Fog::Compute::OrionVM | server', ['orion_vm']) do

  service = Fog::Compute::OrionVM.new
  options = { :hostname => "test.fog_server_#{Time.now.to_i.to_s}", :memory => 1024 }

  tests("instance lifecycle success") do
    @instance = service.servers.new(options)
    @instance.save
    returns(false) { !@instance.persisted? }

    tests("changing ram") do
      pending if Fog.mocking?
      @instance.memory = 2048
      @instance.reload
      returns(2048) { @instance.memory }
    end

    returns(true) { @instance.destroy }
  end

  model_tests(service.servers, options, true) do

    @instance.addresses.create
    @instance.volumes.create(:image => 'ubuntu-oneiric', :size => 50)

    tests('#start').succeeds do
      @instance.start
      @instance.reload
      returns(true) { @instance.state == 'starting' || @instance.state == 'running' }
      @instance.wait_for { ready? }
      @instance.ready?
    end


    tests("#stop").succeeds do
      @instance.stop
      @instance.reload
      @instance.wait_for { stopped? }
      @instance.stopped?
    end

  end
#
#
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

