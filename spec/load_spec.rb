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

  context "process 5000 request simultaneously" do
    it "performs under 3s" do
      expect {
        threads = 1000.times.map do
          Thread.new do
            5.times.each do |time|
              client.puts "set key#{time} 0 0 8"
              client.puts "set_test"
            end
          end
        end
        threads.each(&:join)
      }.to perform_under(3).sec
    end
  end    

end