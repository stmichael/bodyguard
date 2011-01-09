Dir.glob(File.join(File.dirname(__FILE__), "contractor", "*.rb")).each do |f|
  require f
end

Object.send :include, Contractor::Contracts
Object.send :include, Contractor::Callstack
