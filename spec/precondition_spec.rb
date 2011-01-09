describe "Contractor" do
  describe "preconditioned methods" do
    before do
      @object = Contractor::Calculator.new
    end
    it "has a preconditioned method" do
      @object.has_precondition(:sqrt).should be_true
    end
    it "fails if the precondition is invalid" do
      expect{@object.sqrt(-2)}.to raise_error(Contractor::PreconditionViolation)
    end
    it "succeeds if the precondition is valid" do
      expect{@object.sqrt(1)}.to_not raise_error
    end
    it "should return the correct result" do
      @object.sqrt(25).should eql(5.0)
    end
  end
end
