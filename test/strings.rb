require 'test/unit'
require File.dirname(__FILE__) + '/../lib/intersys'

class StringTest < Test::Unit::TestCase
  @@wide_string = "\000\000\000a\000\000\000b\000\000\000c\000\000\000\000"
  @@simple_string = "abc"
  def test_from_wchar
    assert_equal @@simple_string, @@wide_string.from_wchar
  end
  
  def test_to_wchar
    assert_equal @@wide_string, @@simple_string.to_wchar
  end
end