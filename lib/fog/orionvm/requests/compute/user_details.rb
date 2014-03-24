module Fog
  module Compute
    class OrionVM
      class Real

        def user_details(options = nil)
          options ||= {}
          get('user_details', options)
        end

      end
    end
  end
end
