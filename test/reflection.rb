require 'test/unit'
require File.dirname(__FILE__) + '/../lib/intersys'


class MyTest < Intersys::Object
  prefix "Sample"
end

class Article < Intersys::Object
end
class Person < Intersys::Object
end

class ReflectionTest < Test::Unit::TestCase
  def test_methods
    @cdef = Intersys::Reflection::ClassDefinition.open("%Dictionary.ClassDefinition")
    assert_equal "%Dictionary.ClassDefinition", @cdef.name
    assert_equal "persistent", @cdef.class_type
    assert_equal "%Persistent,%Dictionary.ClassDefinitionQuery", @cdef.super
    assert 50 < @cdef.properties.size
    assert 10 < @cdef._methods.size
  end
  
  def test_class_names
    assert_equal MyTest, MyTest.lookup("Sample.MyTest")
    assert_equal Person, Person.lookup("User.Person")
  end
  
  def test_class_create
    return
    @cdef = Intersys::Reflection::ClassDefinition.call("%New", "User.Article")
    @cdef.class_type = "persistent"
    @cdef.super = "%Persistent,%Populate,%XML.Adaptor"
    @cdef.ddl_allowed = true
    @props = @cdef.properties

  @prop = Intersys::Reflection::PropertyDefinition.intersys_call("%New", "Article:Name")
    assert @props << @prop
    @prop.type = "%String"

    @prop = Intersys::Reflection::PropertyDefinition.intersys_call("%New", "Article:SSN")
    assert @props << @prop
    @prop.type = "%String"

    @prop = Intersys::Reflection::PropertyDefinition.intersys_call("%New", "Article:Title")
    assert @props << @prop
    @prop.type = "%String"

    @prop = Intersys::Reflection::PropertyDefinition.intersys_call("%New", "Article:DOB")
    assert @props << @prop
    @prop.type = "%String"
    
    @prop = Intersys::Reflection::PropertyDefinition.intersys_call("%New", "Article:Home")
    assert @props << @prop
    @prop.type = "Sample.Address"
    
    @prop = Intersys::Reflection::PropertyDefinition.intersys_call("%New", "Article:Business")
    assert @props << @prop
    @prop.type = "Sample.Address"
    
    assert_equal "User.Article", @cdef.name
    assert_equal 6, @cdef.properties.size
    assert @cdef.save
  end
  
end

