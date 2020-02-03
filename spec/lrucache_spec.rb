require_relative "spec_helper"
require_relative "../lib/lru_cache"

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
        response = cache.write("write_test", "test", 0, 0)
        expect(response).to eq true
        node = cache.read("write_test")
        expect(node.value).to eq "test"
        expect(cache.head.key).to eq "write_test"
        expect(cache.tail.key).to eq "write_test"
        node = cache.keys["write_test"]
        expect(node.value).to eq "test"
      end

      it "checks head and tail" do
        cache.write("old_key", "test1", 0, 0)
        cache.write("new_key", "test2", 0, 0)
        node = cache.read("new_key")
        expect(node.value).to eq "test2"
        expect(node.next.key).to eq "old_key"
        expect(cache.head.key).to eq "new_key"
        expect(cache.head.next.key).to eq "old_key"
        expect(cache.tail.key).to eq "old_key"
      end
    end

    describe "REMOVE" do
      it "returns true" do
        cache.write("key1", "value1", 0, 0)
        cache.write("key2", "value2", 0, 0)
        cache.write("key3", "value3", 0, 0)
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
        cache.write("key1", "value1", 0, 0)
        response = cache.read("key1")
        expect(response.value).to eq "value1"
        response = cache.keys["key1"]
        expect(response.value).to eq "value1"
      end

      it "sets node to head" do
        cache.write("key1", "value1", 0, 0)
        cache.write("key2", "value2", 0, 0)
        cache.write("key3", "value3", 0, 0)
        expect(cache.head.key).to eq "key3"
        cache.read("key1")
        expect(cache.head.key).to eq "key1"
        expect(cache.head.next.key).to eq "key3"
        expect(cache.tail.key).to eq "key2"
      end
    end

    describe "ENSURE_LIMIT" do
      it "returns nil" do
        cache.write("key1", "value1", 0, 0)
        cache.write("key2", "value2", 0, 0)
        cache.write("key3", "value3", 0, 0)
        cache.write("key4", "value4", 0, 0)
        cache.write("key5", "value5", 0, 0)
        cache.write("key6", "value6", 0, 0)
        
        response = cache.read("key1")
        expect(response).to eq nil
        response = cache.keys["key1"]
        expect(response).to eq nil
        node = cache.read("key2")
        expect(node).to be_truthy
      end
    end

    describe "PURGE" do
      it "returns nil" do
        cache.write("key1", "value1", 0, Time.now + 1)
        cache.write("key2", "value2", 0, Time.now + 4)
        cache.write("key3", "value3", 0, Time.now + 1200)
        
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


        