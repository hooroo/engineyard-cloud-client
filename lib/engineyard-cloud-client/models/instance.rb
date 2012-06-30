require 'engineyard-cloud-client/errors'

module EY
  class CloudClient
    class Instance < ApiStruct.new(:id, :role, :name, :status, :amazon_id, :public_hostname, :environment, :bridge)
      alias hostname public_hostname
      alias bridge? bridge

      # Sizes:
      # 'small'             # Small (32 bit)
      # 'small_64'          # Small (64 bit)
      # 'medium_ram'        # Medium (32 bit)
      # 'medium_ram_64'     # Medium (64 bit)
      # 'large'             # Large (64 bit)
      # 'xlarge'            # Extra Large (64 bit)
      # 'medium_cpu'        # High CPU Medium (32 bit)
      # 'medium_cpu_64'     # High CPU Medium (64 bit)
      # 'xlarge_cpu'        # High CPU Extra Large (64 bit)
      # 'xlarge_ram'        # High Memory Extra Large (64 bit)
      # 'doublexlarge_ram'  # High Memory Double Extra Large (64 bit)
      # 'quadxlarge_ram'    # High Memory Quadruple Extra Large (64 bit)

      def self.create(api, environment, instance_attrs)
        params = instance_attrs.dup # no default fields
        raise EY::CloudClient::AttributeRequiredError.new("role", EY::CloudClient::Environment) unless params["role"]
        raise EY::CloudClient::AttributeRequiredError.new("size", EY::CloudClient::Environment) unless params["size"]
        raise EY::CloudClient::AttributeRequiredError.new("volume_size", EY::CloudClient::Environment) unless params["volume_size"]
        raise EY::CloudClient::AttributeRequiredError.new("environment", EY::CloudClient::Environment) unless environment
        response = api.request("/environments/#{environment.id}/instances", :method => :post, :params => {"instance" => params})
        from_hash(api, response['instance'])
      end

      def initialize(*args)
        super

        raise ArgumentError, 'Malformed instance: no id' unless id
        raise ArgumentError, 'Malformed instance: no role' unless role
        raise ArgumentError, 'Malformed instance: no status' unless status
        raise ArgumentError, 'Malformed instance: no hostname' unless public_hostname
      end

      def has_app_code?
        !["db_master", "db_slave"].include?(role.to_s)
      end

      def terminate
        api.request("/instances/#{id}", :method => :delete)
      end

    end
  end
end
