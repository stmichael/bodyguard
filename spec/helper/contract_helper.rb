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

    postcondition do |a, result|
      result.should > 0
    end
    def square(a)
      a*a
    end

    postcondition do |a, result|
      result.should > 0
    end
    def failing_square(a)
      -5
    end

  end

end
