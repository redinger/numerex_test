require 'rubygems'
require 'hpricot'
require 'open-uri'

URL = "http://deploymanager.ublip.com:8000/deployments.xml"

def get_repo(customer)
  get_field("svn-repo", customer)
end

def get_app_servers(customer)
  get_field("app-server", customer).split(',')
end

def get_staging_app_server(customer)
  get_field("staging-app-server", customer)
end

def get_db_admin(customer)
  get_field("db-admin", customer).eql?("true")
end

def get_app_directory(customer)
  get_field("app-directory", customer)
end

def get_xml()
  Hpricot.XML(open(URL))
end

def get_field(field, customer)
  puts "Retrieveing #{field} for customer: #{customer}"
  doc = get_xml
   (doc/:deployment).each do |deployment_element|
    name = (deployment_element/:customer).inner_html
    if ((deployment_element/:customer).inner_html)==customer
      value = (deployment_element/"#{field}").inner_html
      puts "using #{field}: #{value}"
      return value
    end
  end
  raise Exception.new("No #{field} entry found for customer: #{customer}")
end