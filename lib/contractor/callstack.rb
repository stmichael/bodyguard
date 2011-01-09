module Contractor
  
  module Callstack
    
    def this_method
      caller[0] =~ /`([^']*)'/ and $1.to_sym
    end
    
    def calling_method
      caller[1] =~ /`([^']*)'/ and $1.to_sym
    end
    
  end
  
end