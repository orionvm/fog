require 'fog/core'

module Fog
  module OrionVM
    extend Fog::Provider

    API_V1_URL = "https://panel.orionvm.com.au/api"

    service(:compute, 'Compute')
  end
end

