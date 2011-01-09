describe "Contractor" do
  describe "postconditioned methods" do
    before do
      @object = Contractor::Calculator.new
    end
    it "has a postconditioned method" do
      @object.has_postcondition(:sqrt).should be_true
    end
    it "succeeds if the postcondition is valid" do
      expect{@object.square(5)}.to_not raise_error
    end
    it "fails if the postcondition is invalid" do
      expect{@object.failing_square(5)}.to raise_error(Contractor::PostconditionViolation)
    end
    it "should return the correct result" do
      @object.square(5).should eql(25)
    end
  end
end
