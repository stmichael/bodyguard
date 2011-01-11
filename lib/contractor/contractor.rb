module Contractor

  module UnderContract

    def initialize(*args, &block)
      define_method_wrappers
      super *args, block
    end

    def has_precondition(method)
      self.respond_to? "check_precondition_for_#{method}"
    end

    def has_postcondition(method)
      self.respond_to? "check_postcondition_for_#{method}"
    end

    private

    def define_method_wrappers
      self.class.conditions.each do |key, value|
        define_precondition_method "check_precondition_for_#{key}", value[:preconditions]
        define_postcondition_method "check_postcondition_for_#{key}", value[:postconditions]
        define_method_wrapper key
      end if self.class.conditions
    end

    def define_method_wrapper(method)
      eigenclass.send :alias_method, "original_#{method}".to_sym, method.to_sym
      eigenclass.send :define_method, method do |*args|
        send("check_precondition_for_#{method}", *args)
        result = send("original_#{method}", *args)
        send("check_postcondition_for_#{method}", *args, result)
        result
      end
    end

    def define_precondition_method(name, conditions)
      eigenclass.send :define_method, name do |*args|
        (conditions || []).each do |c|
          begin
            c.call *args
          rescue => e
            raise PreconditionViolation.new(e)
          end
        end
      end
    end

    def define_postcondition_method(name, conditions)
      eigenclass.send :define_method, name do |*args, result|
        (conditions || []).each do |c|
          begin
            c.call *args, result
          rescue => e
            raise PostconditionViolation.new(e)
          end
        end
      end
    end

    def eigenclass
      class << self; self; end
    end
  end

  module ContractDefinitions

    attr_accessor :conditions

    def precondition(&block)
      if block_given?
        attach_contract
        @current_preconditions ||= []
        @current_preconditions << block
      end
    end
    alias :pre :precondition

    def postcondition(&block)
      if block_given?
        attach_contract
        @current_postconditions ||= []
        @current_postconditions << block
      end
    end
    alias :post :postcondition

    private

    def is_contract_attached?
      self.ancestors.include? Contractor::UnderContract
    end

    def attach_contract
      self.send :include, Contractor::UnderContract unless is_contract_attached?
    end

    def method_added(method)
      @current_preconditions ||= []
      @current_postconditions ||= []
      @already_processed ||= []

      return if /^(check_precondition_for_|check_postcondition_for_|original_)/ =~ method or
        @already_processed.include?(method) or
        (@current_preconditions.empty? and @current_postconditions.empty?)

      @already_processed << method
      @last_method = method
      apply_conditions(method)
    end

    def apply_conditions(method)
      self.conditions ||= {}
      self.conditions[method] = {
        :preconditions => @current_preconditions,
        :postconditions => @current_postconditions
      }
      @current_preconditions, @current_postconditions = []
    end

  end

end
