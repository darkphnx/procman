module ProcMan
  class Process
    
    attr_writer :options
    
    # Initializes the new process by receiving it's name
    def initialize(name)
      @name = name
      @constraints = []
    end
    
    # Returns the name of the process
    def name
      @name
    end
    
    # Returns a hash of options which the user has specified
    def options
      @options ||= {}
    end
    
    # Returns the current environment
    def environment
      self.options[:environment] || self.options[:e] || self.options[:env] || 'development'
    end
    
    # Returns the current root directory path
    def root
      @root ||= File.expand_path('./')
    end
    
    ## Returns the current hostname of the machine executing this action
    def host
      @host ||= `hostname -f`.strip
    end

    ## Returns whether this process is explicitly listed
    def manual
      return @manual unless @manual.nil?
      @manual = self.options[:processes] && self.options[:processes].split(',').include?(self.name.to_s)
    end
    
    ## Sets a constraint for this process
    def constraint(hash = {})
      @constraints << Constraint.new(self, hash)
    end
    
    # Specifies whether or not actions for this process should be executed
    # in the current context.
    def execute?
      (@constraints.empty? || @constraints.any?(&:matches?)) &&
      (self.options[:processes].nil? || self.options[:processes].split(',').include?(self.name.to_s))
    end
    
    # Specifies whether or not the provided method has been defined in the Procfile
    # for this process.
    def defined_method?(name)
      instance_variable_get("@#{name}").is_a?(Proc)
    end
        
    # Stores and calls different process actions for this process. If there is no
    # block provided and we don't have a method it will return false otherwise it
    # will store or call the action as appropriate.
    def method_missing(method, &block)
      if block_given?
        instance_variable_set("@#{method}", block)
      elsif block = instance_variable_get("@#{method}")
        block.call
      else
        return false
      end
    end
    
  end
end
