class Purger
  attr_reader :queue

  def initialize
    @queue = [ nil ]
  end

  # Add a expiring key to the queue and sort it using the binary heap algorithm.
  # Code adapted from: https://www.brianstorti.com/implementing-a-priority-queue-in-ruby/

  def add(node)
    @queue << node
    bubble_up(@queue.size - 1)
  end

  def start(seconds)
    Thread.new {
      loop do
        sleep(seconds)
        node = first_queue_node
        while node.element.expired?
          dequeue
          LRUCache.instance.remove(node.key, expired: true)
          node = first_queue_node
        end
      end
    }
  end

  def clear
    @queue = [ nil ]
  end

  private

  def delete(node)
    index = @queue.index(node)
    exchange(index, @queue.size - 1)
    deleted = @queue.pop
    bubble_down(index)
    deleted
  end

  def first_queue_node
    @queue[1]
  end

  def dequeue
    exchange(1, @queue.size - 1)
    max = @queue.pop
    bubble_down(1)
    max
  end

  def bubble_up(index)
    parent_index = (index / 2)

    return if index <= 1
    return if @queue[parent_index].element.exptime <= @queue[index].element.exptime
    exchange(index, parent_index)
    bubble_up(parent_index)
  end

  def bubble_down(index)
    child_index = (index * 2)

    return if child_index > @queue.size - 1

    not_the_last_node = child_index < @queue.size - 1
    left_node = @queue[child_index]
    right_node = @queue[child_index + 1]
    child_index += 1 if not_the_last_node && right_node.element.exptime < left_node.element.exptime

    return if @queue[index].element.exptime <= @queue[child_index].element.exptime

    exchange(index, child_index)
    bubble_down(child_index)
  end

  def exchange(source, target)
    @queue[source], @queue[target] = @queue[target], @queue[source]
  end

end