module Contractor

  module Contracts

    def self.included(base)
      base.extend(ClassMethods)
    end

    def has_precondition(method)
      self.respond_to? "check_precondition_for_#{method}"
    end

    def has_postcondition(method)
      self.respond_to? "check_postcondition_for_#{method}"
    end

    module ClassMethods

      attr_accessor :conditions

      def precondition(&block)
        if block_given?
          @current_preconditions ||= []
          @current_preconditions << block
        end
      end

      def postcondition(&block)
        if block_given?
          @current_postconditions ||= []
          @current_postconditions << block
        end
      end

      private

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
        define_precondition_checker_for method
        define_postcondition_checker_for method
        define_method_wrapper method
      end

      def define_precondition_checker_for(method)
        class_eval do
          define_method "check_precondition_for_#{method}".to_sym do |*args|
            return unless self.class.conditions.include? method
            preconditions = self.class.conditions[method][:preconditions]
            begin
              preconditions.each do |precondition|
                self.instance_exec *args, &precondition
              end
            rescue => e
              raise PreconditionViolation.new(e)
            end
          end
        end
      end

      def define_postcondition_checker_for(method)
        class_eval do
          define_method "check_postcondition_for_#{method}".to_sym do |*args|
            return unless self.class.conditions.include? method
            postconditions = self.class.conditions[method][:postconditions]
            begin
              postconditions.each do |postcondition|
                self.instance_exec *args, &postcondition
              end
            rescue => e
              raise PostconditionViolation.new(e)
            end
          end
        end
      end

      def define_method_wrapper(method)
        class_eval do
          alias_method "original_#{method}".to_sym, method.to_sym
          define_method method do |*args|
            send("check_precondition_for_#{method}", *args)
            result = send("original_#{method}", *args)
            send("check_postcondition_for_#{method}", *args, result)
            result
          end
        end
      end
    end

  end

end
