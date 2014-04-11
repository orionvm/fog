module Fog
  module Compute
    class OrionVM
      class Real

        def drop_vm(vm_id, options = nil)
          options ||= {}
          post('drop_vm', {:vmid => vm_id}, {:response_type => :boolean}.merge(options))
        end

      end

      class Mock
        def drop_vm(vm_id, options = nil)
          response = Excon::Response.new
          Fog::Logger.debug('deleting vm ' + vm_id.to_s)
          if vm_id
            instance = self.data[:instances][vm_id]
            if instance
              Fog::Logger.debug 'vm state' + instance.to_s
              if instance['state'] == 0
                vm = self.data[:instances].delete(vm_id)
                disks = vm['disks']
                vm['disks'] = []
                disks.each {|disk|
                  realdisk = self.data[:disks][disk['name']]
                  realdisk['locked'] = false
                  realdisk['vm'] = nil
                }
                ips = vm['ips']
                vm['ips'] = []
                ips.each {|ip|
                  realip = self.data[:ips][ip]
                  realip['vmid'] = nil
                  realip['locked'] = false
                }
                
                response.status = 200
                response.body = true
                Fog::Logger.debug 'deleted vm' + vm_id.to_s
                return response
              else
                response.status = 200
                response.body = false
                return response
              end
            end
          end
          
          response.status = 400
          raise(Excon::Errors.status_error({:expects => 200}, response))
        end
      end
    end
  end
end
