require 'helper'

class TestDictionary < Test::Unit::TestCase
  def setup
    @dictionary = Rubius::Dictionary.new
  end
  
  context "A Rubius::Dictionary" do
    should "load and parse a RADIUS dictionary file" do
      IO.stubs(:readlines).returns(RADIUS_DICTIONARY)
    
      assert @dictionary.load("file")
    
      assert_equal "Cisco", @dictionary.vendor_name(9)
      assert_equal "Juniper", @dictionary.vendor_name(2636)
      
      assert_equal "Service-Type", @dictionary.attribute_name(6)
      assert_equal "string", @dictionary.attribute_type(2, 9)
      assert_equal 1, @dictionary.attribute_id("Juniper-Local-User-Name", 2636)
    end
  end
end
