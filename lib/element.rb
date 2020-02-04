class Element
    attr_reader :cas_token, :value, :exptime, :bytes, :flags
    
    def initialize(value, flags, exptime)
      @value     = value
      @bytes     = value.size
      @flags     = flags
      @exptime   = exptime
    end

    def assign_token
      @cas_token = self.class.new_cas_token
    end 

    def expires?
      return true if @exptime.is_a?(Time)
      false
    end
  
    def expired?
      return false if @exptime.is_a?(Integer) && @exptime == 0
      return false if @exptime.is_a?(Time) && @exptime > Time.now
      return true 
    end  

    private

    def self.new_cas_token
      @cas_token ||= 0
      @cas_token += 1
    end

  end