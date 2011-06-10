require 'rubygems'
require 'XmlSimple'
require 'open-uri'

class WurflData
  attr_accessor :wurfl_id
  def initialize(device_data)
    @raw_data = device_data
    @wurfl_id = device_data["id"]
  end
  
  def method_missing(method, *args)
    return @raw_data[method.to_s] if @raw_data.keys.include?(method.to_s)
  end
  
  def keys
    return @raw_data.keys
  end
end


class TeraWurfl
  def initialize(tera_wurfl_uri)
    @uri = tera_wurfl_uri
  end
  
  def get_user_agent(user_agent)
    url = "http://#{@uri}/Tera-Wurfl/webservice.php?ua=#{URI.escape user_agent.gsub(' ', '+')}"
    content = open(url).read
    data = XmlSimple.xml_in(content, {'KeyAttr' => 'name', 'ContentKey' => '-value'})
    raise "multiple devices found" if data["device"].size != 1
    device = data["device"][0]["capability"]
    raise "no exact match" if device["match"] != "true"
    wurfl_data = WurflData.new(device)
    return wurfl_data
  end
end

=begin
EXAMPLE
server = TeraWurfl.new("designgonemad.com")
user_agent = "NokiaN70-1/5.0609.2.0.1 Series60/2.8 Profile/MIDP-2.0 Configuration/CLDC-1.1"
wurfl_data = server.get_user_agent(user_agent)
puts(wurfl_data.xhtml_format_as_attribute)
=end