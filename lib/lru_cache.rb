require 'byebug'

require_relative 'lru_cache/node'
require_relative 'lru_cache/purger'

class LRUCache
  attr_reader :size, :limit, :head, :tail, :keys

  class << self
    attr_accessor :instance
  end

  def initialize(limit = 100, seconds_purge = 30)
    validate_singleton_instance!

    @size     = 0
    @limit    = limit
    @keys     = {}
    @purger   = Purger.new
    @mutex    = Mutex.new

    @purger.start(seconds_purge)

    self.class.instance = self
  end

  # If update = true cas_token increments.
  def write(key, element, update: true)
    ensure_limit
    remove(key)
    @mutex.synchronize do
      if head
        node = Node.new(key, element, update: update)
        node.next = head
        head.prev = node

        @head = node
      else
        node = Node.new(key, element, next_node: head, update: update)
        @head = @tail = node
      end

      if node.element.expires?
        @purger.add(node)
      end

      @keys[key] = head
      @size += 1
      true
    end
  end

  # if read = true node isn't removed from purger , if expired = true node has been removed by purger 
  def remove(key, read: false, expired: false)

    @mutex.synchronize do
      node = @keys[key]
      return unless node

      if node.prev
        node.prev.next = node.next
      else
        @head = node.next
      end

      if node.next
        node.next.prev = node.prev
      else
        @tail = node.prev
      end

      if node.element.expires? && !read && !expired
        @purger.delete(node)
      end

      @keys.delete(key)
      @size = @size - 1
      true
    end
  end

  def read(key)

    return unless !@keys[key].nil? 
    return unless !@keys[key].element.expired?
    node = @keys[key]
    
    remove(key, read: true)
  
    write(key, node.element, update: false)

    node.element
  end

  def clear
    @size = 0
    @keys = {}
    @head = nil
    @tail = nil
    @purger.clear
  end

  private 

  def validate_singleton_instance!
    if self.class.instance
      raise "Can't be instanced"
    end
  end


  # dequeues linked list if limit is reached
  def ensure_limit
    if @size == @limit
      remove(@tail.key)
    end
  end

end
