class Node
  attr_reader :cas_token, :key, :value, :exptime, :bytes, :flags
  attr_accessor :next, :prev

  def initialize(key, value, flags, exptime, cas_token = nil, next_node: nil, update: true)
    @key       = key
    @value     = value
    @bytes     = value.size
    @flags     = flags
    @exptime   = exptime
    @next      = next_node # next is a reserved keyword
    @cas_token = update ? self.class.new_cas_token : cas_token  
  end

  def self.new_cas_token
    @cas_token ||= 0
    @cas_token += 1
  end

  def expired?
    return false if @exptime.is_a?(Integer) && @exptime == 0
    return false if @exptime.is_a?(Time) && @exptime > Time.now
    return true 
  end  
end