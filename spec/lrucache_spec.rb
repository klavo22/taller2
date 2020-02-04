require_relative "spec_helper"
require_relative "../lib/lru_cache"
require_relative "../lib/element"

describe LRUCache do

    let(:cache) { LRUCache.instance }

    before(:all) do
      LRUCache.new(5, 3)
    end
    
    after(:each) do
      LRUCache.instance.clear
    end

    describe "WRITE" do
      it "returns true" do
        element1 = Element.new("test", 0, 0)
        response = cache.write("write_test", element1)
        expect(response).to eq true
        element = cache.read("write_test")
        expect(element.value).to eq "test"
        expect(cache.head.key).to eq "write_test"
        expect(cache.tail.key).to eq "write_test"
        element = cache.keys["write_test"].element
        expect(element.value).to eq "test"
      end

      it "checks head and tail" do
        element1 = Element.new("test1", 0, 0)
        cache.write("old_key", element1)
        element2 = Element.new("test2", 0, 0)
        cache.write("new_key", element2)
        node = cache.keys["new_key"]
        expect(node.element.value).to eq "test2"
        expect(node.next.key).to eq "old_key"
        expect(cache.head.key).to eq "new_key"
        expect(cache.head.next.key).to eq "old_key"
        expect(cache.tail.key).to eq "old_key"
      end
    end

    describe "REMOVE" do
      it "returns true" do
        element1 = Element.new("value1", 0, 0)
        cache.write("key1", element1)
        element2 = Element.new("value2", 0, 0)
        cache.write("key2", element2)
        element3 = Element.new("value3", 0, 0)
        cache.write("key3", element3)
        response = cache.remove("key2")
        expect(response).to eq true
        expect(cache.head.next.key).to eq "key1"
        expect(cache.tail.key).to eq "key1"
        expect(cache.head.key).to eq "key3"
        response = cache.keys["key2"]
        expect(response).to eq nil
      end

      it "returns nil" do
        response = cache.remove("false_key")
        expect(response).to eq nil
        response = cache.keys["false_key"]
        expect(response).to eq nil
      end
    end

    describe "READ" do
      it "returns node" do
        element1 = Element.new("value1", 0, 0)
        cache.write("key1", element1)
        response = cache.read("key1")
        expect(response.value).to eq "value1"
        response = cache.keys["key1"].element
        expect(response.value).to eq "value1"
      end

      it "sets node to head" do
        element1 = Element.new("value1", 0, 0)
        cache.write("key1", element1)
        element2 = Element.new("value2", 0, 0)
        cache.write("key2", element2)
        element3 = Element.new("value3", 0, 0)
        cache.write("key3", element3)
        expect(cache.head.key).to eq "key3"
        cache.read("key1")
        expect(cache.head.key).to eq "key1"
        expect(cache.head.next.key).to eq "key3"
        expect(cache.tail.key).to eq "key2"
      end
    end

    describe "ENSURE_LIMIT" do
      it "returns nil" do
        element1 = Element.new("value1", 0, 0)
        cache.write("key1", element1)
        element2 = Element.new("value2", 0, 0)
        cache.write("key2", element2)
        element3 = Element.new("value3", 0, 0)
        cache.write("key3", element3)
        element4 = Element.new("value4", 0, 0)
        cache.write("key4", element4)
        element5 = Element.new("value5", 0, 0)
        cache.write("key5", element5)
        element6 = Element.new("value6", 0, 0)
        cache.write("key6", element6)
        
        response = cache.read("key1")
        expect(response).to eq nil
        response = cache.keys["key1"]
        expect(response).to eq nil
        element = cache.read("key2")
        expect(element).to be_truthy
      end
    end

    describe "PURGE" do
      it "returns nil" do
        element1 = Element.new("value1", 0, Time.now + 1)
        cache.write("key1", element1)
        element2 = Element.new("value2", 0, Time.now + 4)
        cache.write("key2", element2)
        element3 = Element.new("value3", 0, Time.now + 1200)
        cache.write("key3", element3)
        
        sleep(2)
        response1 = cache.read("key1")
        expect(response1).to be_falsey
        response2 = cache.keys["key1"]
        expect(response2).to be_truthy
        sleep(2)
        response3 = cache.keys["key1"]
        expect(response3).to be_falsey
        response4 = cache.read("key2")
        expect(response4).to be_falsey
        response5 = cache.keys["key2"]
        expect(response5).to be_truthy
        response6 = cache.keys["key3"]
        expect(response6).to be_truthy
        sleep(3)
        response7 = cache.keys["key2"]
        expect(response7).to be_falsey
        response8 = cache.keys["key3"]
        expect(response8).to be_truthy
      end
    end
        
end


        