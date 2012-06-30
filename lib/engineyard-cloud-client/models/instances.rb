require 'engineyard-cloud-client/models/instance'

module EY
  class CloudClient
    class Instances
      def initialize(environment)
        @environment = environment
        @count = @environment.instances_count
      end

      def count
        @count
      end

      def to_a
        @instances ||= request_instances
      end

      def add(instance_attrs)
        if none?
          raise "Instances cannot be added to an environment that is not booted."
        end

        instance = Instance.create(api, @environment, instance_attrs)
        @instances = nil
        @count += 1
        instance
      end

      def none?
        count.zero?
      end

      def deploy_to
        select { |inst| inst.has_app_code? }
      end

      def bridge
        @bridge ||= detect { |inst| inst.bridge? }
      end

      def bridge!(ignore_bad_bridge = false)
        if bridge.nil?
          raise NoBridgeError.new(name)
        elsif !ignore_bad_bridge && bridge.status != "running"
          raise BadBridgeStatusError.new(bridge.status, EY::CloudClient.endpoint)
        end
        bridge
      end

      def update
        api.request("/environments/#{id}/update_instances", :method => :put)
        true # raises on failure
      end
      alias rebuild update

      protected

      def set_instances(instances_attrs)
        @instances = load_instances(instances_attrs)
      end

      def request_instances
        if none?
          []
        else
          instances_attrs = api.request("/environments/#{id}/instances")["instances"]
          loaded_instances = load_instances(instances_attrs)
          @count = loaded_instances.size
          loaded_instances
        end
      end

      def load_instances(instances_attrs)
        Instance.from_array(api, instances_attrs, 'environment' => self)
      end

    end
  end
end
