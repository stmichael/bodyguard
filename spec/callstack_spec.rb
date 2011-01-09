describe "Contractor" do
  describe "callstack" do
    before do
      @object = Contractor::CallbackHelper.new
    end
    it "tells the called method" do
      @object.caller_method.should include(:callee)
      @object.caller_method[:callee].should == :called_method
    end
    it "tells the caller method" do
      @object.caller_method.should include(:caller)
      @object.caller_method[:caller].should == :caller_method
    end
  end
end
