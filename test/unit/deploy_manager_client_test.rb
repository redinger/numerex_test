require "test/unit"
require "config/deploy_manager_client"

class DeployManagerClientTest < Test::Unit::TestCase
  
module XMLMock
  def get_xml
    open("test/unit/deploy_manager_test.xml") { |f| Hpricot(f) }
  end
end
  
  
def test_client
  self.extend(XMLMock)
  assert_equal "https://a.b.c", get_repo("myfleet")
  assert_equal "1.2.3.4", get_app_servers("myfleet")[0]
  assert_equal "/data", get_app_directory("myfleet")
  assert_equal "q.w.e/trunk", get_repo("cyberdyne")
  assert_equal ["1.2.3.4:1234", "5.6.7.8:5678"], get_app_servers("cyberdyne")
end
  
  
end