Dir.glob(File.join(File.dirname(__FILE__), "contractor", "*.rb")).each do |f|
  require f
end

Class.send :include, Contractor::ContractDefinitions
Object.send :include, Contractor::Callstack
