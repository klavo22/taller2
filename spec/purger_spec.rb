require_relative "spec_helper"
require_relative "../lib/lru_cache/node"
require_relative "../lib/lru_cache/purger"
require_relative "../lib/element"


describe Purger do
  
  let(:purger) { Purger.new }

  describe "ADD" do
    it "adds node to queue" do
      element = Element.new("value1", 0,Time.now + 30)
      node = Node.new("key1", element)
      purger.add(node)
      response = purger.queue[1]
      expect(response.key).to eq "key1"
    end

    it "returns nil" do
      element = Element.new("value1", 0,Time.now + 1)
      node = Node.new("key1", element)
      purger.add(node)
      purger.start(1)
      sleep(2)
      response = purger.queue[1]
      expect(response).to be_falsey 
    end

    it "sorts correctly" do
      element = Element.new("value1", 0, Time.now + 300)
      node1 = Node.new("key1", element)
      element2 = Element.new("value2", 0, Time.now + 150)
      node2 = Node.new("key2", element2)
      element3 = Element.new("value3", 0, Time.now + 200)
      node3 = Node.new("key3", element3)
      purger.add(node1)
      purger.add(node2)
      purger.add(node3)
      response = purger.queue[1]
      expect(response).to eq node2
    end
  end

  describe "DELETE" do
    it "removes from queue" do
      element = Element.new("value1", 0, Time.now + 30)
      node = Node.new("key1", element)
      purger.add(node)
      response = purger.queue.include?(node)
      expect(response).to eq true
    end

    it "sorts correctly" do
      element1 = Element.new("value1", 0, Time.now + 300)
      node1 = Node.new("key1", element1)
      element2 = Element.new("value2", 0, Time.now + 150)
      node2 = Node.new("key2", element2)
      element3 = Element.new("value3", 0, Time.now + 200)
      node3 = Node.new("key3", element3)
      element4 = Element.new("value4", 0, Time.now + 100)
      node4 = Node.new("key4", element4)
      purger.add(node1)
      purger.add(node2)
      purger.add(node3)
      purger.add(node4)
      response = purger.queue[1]
      expect(response).to eq node4
      purger.send(:delete, node4)
      response = purger.queue[1]
      expect(response).to eq node2
    end
  end

  describe "DEQUEUE" do
    it "removes first element" do
      element1 = Element.new("value1", 0, Time.now + 300)
      node1 = Node.new("key1", element1)
      element2 = Element.new("value2", 0, Time.now + 150)
      node2 = Node.new("key2", element2)
      element3 = Element.new("value3", 0, Time.now + 200)
      node3 = Node.new("key3", element3)
      element4 = Element.new("value4", 0, Time.now + 100)
      node4 = Node.new("key4", element4)
      purger.add(node1)
      purger.add(node2)
      purger.add(node3)
      purger.add(node4)
      response = purger.queue[1]
      expect(response).to eq node4
      purger.send(:dequeue)
      response = purger.queue[1]
      expect(response).to eq node2        
    end
  end
end