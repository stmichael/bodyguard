module Contractor

  module Contracts

    def self.included(base)
      base.extend(ClassMethods)
    end

    def has_precondition(method)
      self.respond_to? "check_precondition_for_#{method}"
    end

    module ClassMethods

      attr_accessor :conditions

      def precondition(&block)
        if block_given?
          @current_preconditions ||= []
          @current_preconditions << block
        end
      end

      private

      def method_added(method)
        @current_preconditions ||= []
        @already_processed ||= []

        return if /^(check_precondition_for_|original_)/ =~ method or @current_preconditions.empty? or @already_processed.include?(method)

        @already_processed << method
        apply_conditions(method)
      end

      def apply_conditions(method)
        self.conditions ||= {}
        self.conditions[method] = {
          :preconditions => @current_preconditions
        }
        @current_preconditions = []
        define_precondition_checker_for method
        define_method_wrapper method
      end

      def define_precondition_checker_for(method)
        class_eval do
          define_method "check_precondition_for_#{method}".to_sym do |*args|
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

      def define_method_wrapper(method)
        precondition_method = "check_precondition_for_#{method}"
        postcondition_method = "check_postcondition_for_#{method}"
        class_eval do
          alias_method "original_#{method}".to_sym, method.to_sym
          define_method method do |*args|
            send("check_precondition_for_#{method}", *args)
            result = send("original_#{method}", *args)
          end
        end
      end
    end

  end

end
