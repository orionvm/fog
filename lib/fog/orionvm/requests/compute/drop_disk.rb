module Fog
  module Compute
    class OrionVM
      class Real
        
        def drop_disk(disk_name, options = nil)
          options ||= {}
          post('drop_disk', {:diskname => disk_name}, {:response_type => :boolean}.merge(options))
        end
        
      end
      
      class Mock
        
        def drop_disk(disk_name, options = nil)
          response = Excon::Response.new
          response.body = true
          
          name = disk_name
          disk = self.data[:disks][name]
  
          if !disk
            response.body = "disk not found with name #{name}"
          elsif disk['locked']
            response.body = 'disk is locked'
          end
          
         
          if response.body == true
            self.data[:disks].delete(disk_name)
            response.status = 200
            return response
          else
            response.status = 400
            raise(Excon::Errors.status_error({:expects => 200}, response))
          end
        end
        
      end
      
    end
  end
end
