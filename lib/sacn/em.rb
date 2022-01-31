class Sacn::EMServer < EM::Connection

  attr_reader :sacn

  def initialize
    @sacn = Sacn::IO.new(false)
    puts "init emserver"
  end

  def receive_data(data)
    # puts "receive_data emserver"
    # puts data.inspect
    sender = Socket.unpack_sockaddr_in(get_peername)
    #TODO: sender_addrinfo and EM get_peername
    sender = ["AF_INET", sender[0], sender[1], sender[1]] 
    @sacn.process_data(data, sender)
    # EM.stop
  end

  def self.init_me(address = '0.0.0.0', port = Sacn::IO::PORT, &block)
    puts "Sacn::EMServer init_me (#{address}:#{port})"
    # @sacn = Sacn::IO.new(false)
    # EM::open_datagram_socket('192.168.0.203', Sacn::IO::PORT, self, &block)
    EM::open_datagram_socket(address, port, self, &block)
  end

  

  def self.test_me &block
    # EM::open_datagram_socket('192.168.0.203', Sacn::IO::PORT, self) do |s|
    # init_me('0.0.0.0') do |s|
    init_me do |s|
      s.sacn.on :data do |data|
        puts "Sacn data - #{data[:packet].inspect}"
      end
      block.call(s) if block_given?
    end
  end

end