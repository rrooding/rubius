require 'helper'

class TestDictionary < Test::Unit::TestCase
  context "A Rubius::Dictionary" do
    setup do
      @dictionary = Rubius::Dictionary.new
    end
    
    context "provided with a valid RADIUS dictionary file" do
      setup do
        IO.stubs(:readlines).returns(RADIUS_DICTIONARY)
      end
      
      should "load and parse it" do
        assert @dictionary.load("filename")
        
        assert_equal "Cisco", @dictionary.vendor_name(9)
        assert_equal "Juniper", @dictionary.vendor_name(2636)

        assert_equal "Service-Type", @dictionary.attribute_name(6)
        assert_equal "string", @dictionary.attribute_type(2, 9)
        assert_equal 1, @dictionary.attribute_id("Juniper-Local-User-Name", 2636)
      end
    end
    
    context "provided with a non-existant RADIUS dictionary file" do
      setup do
        IO.stubs(:readlines).raises(Errno::ENOENT)
      end
      
      should "raise an exception" do
        assert_raise Rubius::InvalidDictionaryError do
          @dictionary.load("/no/existing/file")
        end
      end
    end
    
    context "provided with a malformed RADIUS dictionary file" do
      should "handle broken VENDOR lines" do
        IO.stubs(:readlines).returns(RADIUS_DICTIONARY+DICT_BROKEN_VENDOR)
        
        assert @dictionary.load("filename")
        
        assert !@dictionary.vendors.include?("Microsoft")
        assert_nil @dictionary.attribute_name(8344)
        
        assert @dictionary.vendors.include?("Apple")
        assert_equal "Is-Cool", @dictionary.attribute_name(1337, 25)
        
        assert !@dictionary.vendors.include?("NoId")
      end
      
      should "handle broken ATTRIBUTE lines" do
        IO.stubs(:readlines).returns(RADIUS_DICTIONARY+DICT_BROKEN_ATTR)
        
        assert @dictionary.load("filename")
        
        assert_equal 'IBM-Attr-Included', @dictionary.attribute_name(5137, 123)
        assert_nil @dictionary.attribute_name(5138, 123)
        assert_equal 'IBM-Attr-Included2', @dictionary.attribute_name(5139, 123)
      end
      
      should "handle broken VALUE lines" do
        
      end
    end
  end
end
