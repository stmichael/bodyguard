module Contractor
  class CallbackHelper

    def caller_method
      called_method
    end

    def called_method
      {:callee => this_method, :caller => calling_method}
    end

  end

  class Calculator

    precondition do |a|
      a.should >= 0
    end
    def sqrt(a)
      Math.sqrt(a)
    end

  end

end
