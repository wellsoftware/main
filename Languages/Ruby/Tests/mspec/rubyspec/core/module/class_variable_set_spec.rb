require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/fixtures/classes'

describe "Module#class_variable_set" do
  it "sets the class variable with the given name to the given value" do
    c = Class.new

    c.send(:class_variable_set, :@@test, "test")
    c.send(:class_variable_set, "@@test3", "test3")

    c.send(:class_variable_get, :@@test).should == "test"
    c.send(:class_variable_get, :@@test3).should == "test3"
  end

  it "sets the value of a class variable with the given name defined in an included module" do
    c = Class.new { include ModuleSpecs::MVars }
    c.send(:class_variable_set, "@@mvar", :new_mvar).should == :new_mvar
    c.send(:class_variable_get, "@@mvar").should == :new_mvar
  end

  ruby_version_is ""..."1.9" do
    not_compliant_on :rubinius do
      it "accepts Fixnums for class variables" do
        c = Class.new
        c.send(:class_variable_set, :@@test2.to_i, "test2")
        c.send(:class_variable_get, :@@test2).should == "test2"
      end
    end
  end

  ruby_version_is ""..."1.9" do
    it "raises a TypeError when self is frozen" do
      lambda {
        Class.new.freeze.send(:class_variable_set, :@@test, "test")
      }.should raise_error(TypeError)
      lambda {
        Module.new.freeze.send(:class_variable_set, :@@test, "test")
      }.should raise_error(TypeError)
    end
  end

  ruby_version_is "1.9" do
    it "raises a RuntimeError when self is frozen" do
      lambda {
        Class.new.freeze.send(:class_variable_set, :@@test, "test")
      }.should raise_error(RuntimeError)
      lambda {
        Module.new.freeze.send(:class_variable_set, :@@test, "test")
      }.should raise_error(RuntimeError)
    end
  end

  it "raises a NameError when the given name is not allowed" do
    c = Class.new

    lambda {
      c.send(:class_variable_set, :invalid_name, "test")
    }.should raise_error(NameError)
    lambda {
      c.send(:class_variable_set, "@invalid_name", "test")
    }.should raise_error(NameError)
  end

  it "converts a non string/symbol/fixnum name to string using to_str" do
    (o = mock('@@class_var')).should_receive(:to_str).and_return("@@class_var")
    c = Class.new
    c.send(:class_variable_set, o, "test")
    c.send(:class_variable_get, :@@class_var).should == "test"
  end

  it "raises a TypeError when the given names can't be converted to strings using to_str" do
    c = Class.new { class_variable_set :@@class_var, "test" }
    o = mock('123')
    lambda { c.send(:class_variable_set, o, "test") }.should raise_error(TypeError)
    o.should_receive(:to_str).and_return(123)
    lambda { c.send(:class_variable_set, o, "test") }.should raise_error(TypeError)
  end
end
