class Gateway
  attr_accessor :name,:label,:overview_uri,:device_uri,:device_class
  
  @@gateway_lookup = {}
  @@gateway_list = []
  Dir["config/*_gateway.yml"].sort.each do | config_file |
    
    gateway_config = YAML::load_file(config_file)
    
    gateway = Gateway.new
    gateway.name = gateway_config["name"]
    gateway.label = gateway_config["label"]
    gateway.overview_uri = gateway_config["overview_uri"]
    gateway.device_uri = gateway_config["device_uri"]
    gateway.device_class = gateway_config["device_class"]
    
    @@gateway_list.push gateway
    @@gateway_lookup[gateway.name] = gateway
  end
  
  def self.find(name)
    @@gateway_lookup[name]
  end
  
  def self.all
    @@gateway_list
  end
end
