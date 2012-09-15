class OrionVM < Fog::Bin
  class << self

    def class_for(key)
      case key
      when :compute
        Fog::Compute::OrionVM
      else
        raise ArgumentError, "Unsupported #{self} service: #{key}"
      end
    end

    def [](service)
      @@connections ||= Hash.new do |hash, key|
        hash[key] = case key
        when :compute
          Fog::Logger.warning("OrionVM[:compute] is not recommended, use Compute[:orion_vm] for portability")
          Fog::Compute.new(:provider => 'OrionVM')
        else
          raise ArgumentError, "Unrecognized service: #{service}"
        end
      end
      @@connections[service]
    end

    def services
      Fog::OrionVM.services
    end

  end
end

