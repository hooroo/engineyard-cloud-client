require 'dm-core'

class Instance
  include DataMapper::Resource

  property :id,              Serial
  property :name,            String
  property :role,            String
  property :size,            String
  property :volume_size,     String
  property :status,          String, :default => 'starting'
  property :amazon_id,       String
  property :public_hostname, String, :default => 'default.hostname'

  belongs_to :environment

  def inspect
    "#<Instance environment:#{environment.name} role:#{role} status:#{status} hostname:#{public_hostname} name:#{name}>"
  end

  def bridge
    %w[app_master solo].include?(role)
  end

end
