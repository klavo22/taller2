require_relative "spec_helper"
require_relative "../server"


describe Server do
  let(:client) { TCPSocket.open('localhost', 1891)}

  before(:all) do
    @thread = Thread.new { Server.new(1891).start }
  end

  after(:all) do
    Thread.kill(@thread)
  end
  
  describe "SET" do
    context "with valid params" do
      it "returns STORED" do
        
        client.puts "set setted 0 0 8"
        client.puts "set_test"
        message = client.gets
        expect(message).to eq "STORED\r\n"

        client.puts "get setted"
        client.gets
        getmessage = client.gets
        expect(getmessage).to eq "set_test\r\n"
      end
    end

    context "with wrong command" do
      it "returns ERROR" do
        client.puts "pet klavo 0 0 5"
        message = client.gets
        expect(message).to eq "ERROR\r\n"
      end
    end 

    context "missing a parameter" do
      it "returns ERROR" do
        client.puts "set klavo 0 5"
        message = client.gets
        expect(message).to eq "ERROR\r\n"
      end
    end 

    context "missing key" do
      it "returns ERROR" do
        client.puts "set 0 0 5"
        message = client.gets
        expect(message).to eq "ERROR\r\n"
      end
    end 

    context "with non-numeric flags" do
      it "returns CLIENT_ERROR bad command line format" do
        client.puts "set klavo a 0 5"
        message = client.gets
        expect(message).to eq "CLIENT_ERROR bad command line format\r\n"
      end
    end
    
    context "with non-numeric expiration time" do
      it "returns CLIENT_ERROR bad command line format" do
        client.puts "set klavo 0 a 5"
        message = client.gets
        expect(message).to eq "CLIENT_ERROR bad command line format\r\n"
      end
    end
    
    context "with invalid flags" do
      it "returns CLIENT_ERROR bad command line format" do
        client.puts "set klavo 4294967296 0 5"
        message = client.gets
        expect(message).to eq "CLIENT_ERROR bad command line format\r\n"
      end
    end

    context "with negative expiration time" do
      it "returns STORED" do
        
        client.puts "set expired 0 -1 7"
        client.puts "expired"
        message = client.gets
        expect(message).to eq "STORED\r\n"

        client.puts "get expired"
        response = client.gets
        expect(response).to eq "END\r\n"
      end
    end

    context "with positive expiration time" do
      it "returns STORED" do
        
        client.puts "set expired2 0 4 12 noreply"
        client.puts "expired_test"

        sleep(2)
        client.puts "get expired2"
        client.gets
        response1 = client.gets
        expect(response1).to eq "expired_test\r\n"
        sleep(2)
        client.puts "get expired2"
        message2 = client.gets
        expect(message2).to eq "END\r\n"
      end
    end
  
  end

  describe "ADD" do
    context "with valid params" do
      it "returns STORED" do
        client.puts "add added1 0 0 8"
        client.puts "addtest1"
        message = client.gets
        expect(message).to eq "STORED\r\n"

        client.puts "get added1"
        client.gets
        getmessage = client.gets 
        expect(getmessage).to eq "addtest1\r\n"
      end
    end

    context "with existing key" do
      it "returns NOT_STORED" do
        
        client.puts "add added2 0 0 8 noreply"
        client.puts "addtest2"
        client.puts "add added2 0 0 12"
        client.puts "addtestwrong"
        message = client.gets
        expect(message).to eq "NOT_STORED\r\n"

        client.puts "get added2"
        client.gets
        getmessage = client.gets
        expect(getmessage).to eq "addtest2\r\n"
      end
    end
  end

  describe "REPLACE" do
    context "with valid params" do
      it "returns STORED" do
        
        client.puts "set replaced1 0 0 4 noreply"
        client.puts "test"
        client.puts "replace replaced1 0 0 13"
        client.puts "replacedtest1"
        message = client.gets
        expect(message).to eq "STORED\r\n"

        client.puts "get replaced1"
        client.gets
        getmessage = client.gets
        expect(getmessage).to eq "replacedtest1\r\n"
      end
    end

    context "with non-existing key" do
      it "returns NOT_STORED" do
        
        client.puts "replace falsekey 0 0 9"
        client.puts "falsetest"
        message = client.gets
        expect(message).to eq "NOT_STORED\r\n"
        
      end
    end
  end

  describe "APPEND" do
    context "with valid params" do
      it "returns STORED" do
        
        client.puts "set appended 0 0 4 noreply"
        client.puts "test"
        
        client.puts "append appended 0 0 8"
        client.puts "appended"
        message = client.gets
        expect(message).to eq "STORED\r\n"
        
        client.puts "get appended"
        client.gets
        getmessage = client.gets
        expect(getmessage).to eq "testappended\r\n"
      end
    end
  end
  
  describe "PREPEND" do
    context "with valid params" do
      it "returns STORED" do
        
        client.puts "set prepended 0 0 4 noreply"
        client.puts "test"
        
        client.puts "prepend prepended 0 0 9"
        client.puts "prepended"
        message = client.gets
        expect(message).to eq "STORED\r\n"
        
        client.puts "get prepended"
        client.gets
        getmessage = client.gets
        expect(getmessage).to eq "prependedtest\r\n"
      end
    end
  end

  describe "CAS" do
    context "valid params" do
      it "returns STORED" do
        client.puts "set castest 0 0 4 noreply"
        client.puts "test"
        client.puts "cas castest 0 0 8 12"
        client.puts "castest2"
        message = client.gets
        expect(message).to eq "STORED\r\n"
      end
    end

    context "with incorrect cas token" do

      it "returns EXISTS" do
        client.puts "set castest2 0 0 5 noreply"
        client.puts "test2"
        client.puts "cas castest2 0 0 5 20"
        client.puts "test3"
        message = client.gets
        expect(message).to eq "EXISTS\r\n"
      end
    end

    context "with non-existing key" do
      it "returns NOT_FOUND" do
        client.puts "cas falsekey 0 0 5 8"
        client.puts "false"
        message = client.gets
        expect(message).to eq "NOT_FOUND\r\n"
      end
    end

    context "with wrong token" do
      it "returns CLIENT_ERROR bad command line format" do
        client.puts "cas wrongtoken 0 0 5 18446744073709551616"
        message = client.gets
        expect(message).to eq "CLIENT_ERROR bad command line format\r\n"
      end
    end

    context "without cas token" do
      it "returns ERROR" do
        client.puts "cas notoken 0 0 5"
        message = client.gets
        expect(message).to eq "ERROR\r\n"
      end
    end

    context "with negative token" do
      it "returns CLIENT_ERROR bad command line format" do
        client.puts "cas negativetoken 0 0 5 -1"
        message = client.gets
        expect(message).to eq "CLIENT_ERROR bad command line format\r\n"
      end
    end
  end

  describe "GET" do
    it "returns multiple values" do
      client.puts "set gettest 0 0 8 noreply"
      client.puts "gettest1"
      client.puts "set gettest2 0 0 8 noreply"
      client.puts "gettest2"
      client.puts "get gettest gettest2"
      client.gets
      response = client.gets
      expect(response).to eq "gettest1\r\n"
      client.gets
      response = client.gets
      expect(response).to eq "gettest2\r\n"
    end
  end
end