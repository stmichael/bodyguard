require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Contractor" do
  describe "access" do
    it "inherits from Contractor" do
      Class.ancestors.should include(Contractor::ContractDefinitions)
    end
    it "has method precondition" do
      Class.respond_to?(:precondition).should be_true
    end
  end

  describe "contracted object" do
    before do
      @object = Contractor::Calculator.new
    end
    it "inherits from UnderContract" do
      @object.kind_of? Contractor::UnderContract
    end
    it "can check for preconditions" do
      @object.respond_to? :has_precondition
    end
    it "can check for postconditions" do
      @object.respond_to? :has_postcondition
    end
  end
end
