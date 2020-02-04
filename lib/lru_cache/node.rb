class Node
  attr_reader :key, :element
  attr_accessor :next, :prev

  def initialize(key, element, next_node: nil, update: true)
    @key     = key
    @element = element
    @next    = next_node # next is a reserved keyword

    @element.assign_token if update
  end

end