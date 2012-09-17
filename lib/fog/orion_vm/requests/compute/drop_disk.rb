module Fog
  module Compute
    class OrionVM
      class Real
        
        def drop_disk(disk_name, options = nil)
          options ||= {}
          post('drop_disk', {:diskname => disk_name}, {:response_type => :boolean}.merge(options))
        end
        
      end
    end
  end
end
