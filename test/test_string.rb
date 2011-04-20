require 'helper'

class TestString < Test::Unit::TestCase
  should "define a xor method" do
    assert String.method_defined?(:xor)
  end
  
  should "return correct string when xor-ed with an empty string" do
    str1 = "test string"
    str2 = ""
    
    result = str1.xor(str2)
    assert_equal str1, result
    
    result2 = result.xor(str2)
    assert_equal str1, result2
  end
  
  should "return correct string when xor-ed with a longer string" do
    str1 = "test string"
    str2 = "longer test string"
    
    result = str1.xor(str2)
    assert_equal "\x18\n\x1D\x13E\x01T\x06\f\x1D\x13", result
    
    result2 = result.xor(str2)
    assert_equal str1, result2
  end
  
  should "return correct string when xor-ed with a shorter string" do
    str1 = "test string"
    str2 = "short s"
    
    result = str1.xor(str2)
    assert_equal "\a\r\x1C\x06TS\a\x01\x01\x01\x15", result
    
    result2 = result.xor(str2)
    assert_equal str1, result2
  end
end
