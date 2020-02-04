module RequestProcessor
  extend self

  STORED     = "STORED\r\n"
  NOT_STORED = "NOT_STORED\r\n"
  NOT_FOUND  = "NOT_FOUND\r\n"
  EXISTS     = "EXISTS\r\n"

  def set(data)
    set_values(data)
    STORED 
  end

  def add(data)
    if !read(data[:key])
      set_values(data)
      STORED
    else
      NOT_STORED
    end
  end

  def replace(data)
    if read(data[:key])
      set_values(data)
      STORED
    else
      NOT_STORED
    end
  end

  def append(data)
    if update(:concat, data)
      STORED
    else
      NOT_STORED
    end
  end

  def prepend(data)
    if update(:prepend, data)
      STORED
    else
      NOT_STORED
    end
  end

  def cas(data)
    record = read(data[:key])
    if record
      if record.cas_token == data[:cas_token]
        set_values(data)
        return STORED
      else
        return EXISTS
      end
    end
    NOT_FOUND
  end

  def get(data)
    response = ''
    data[:keys].each do |key|
      record = read(key)
      if record
        id = data[:command] == "gets" ? " #{record.cas_token}"  : ''
        response += "VALUE #{key} #{record.flags} #{record.bytes}#{id}\r\n#{record.value}\r\n"
      end
    end
    response += "END\r\n"
  end
  
  alias_method :gets, :get
  
  private

  def write(key, element)
    LRUCache.instance.write(key, element)
  end

  def read(key)
    LRUCache.instance.read(key)
  end

  def set_values(data)
    write(data[:key], data[:element])
  end

  def update(type, data)
    record  = read(data[:key])
    updated_value = data[:element].value
    if record
      element = Element.new(record.value.send(type, updated_value), record.flags, record.exptime)
      write(data[:key], element)
      return true
    end
    false
  end

end