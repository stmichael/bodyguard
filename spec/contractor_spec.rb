require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Contractor" do
  describe "contracts" do
    it "inherited from Contractor" do
      Object.ancestors.should include(Contractor::Contracts)
    end
    it "has method precondition" do
      Object.respond_to?(:precondition).should be_true
    end
  end
end
