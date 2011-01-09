module Contractor

  class ContractorError < StandardError
    attr_reader :source

    def initialize(source)
      @source = source
    end
  end

  class PreconditionViolation < ContractorError
  end

  class PostconditionViolation < ContractorError
  end

  class InvariantViolation < ContractorError
  end

end
