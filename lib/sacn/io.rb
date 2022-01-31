# require 'async/io'

require 'ipaddr'
require 'socket'

require 'uuidtools'

module Sacn
  class IO

    #DATA_LOSS_TIMEOUT = 2.5.seconds # E131_NETWORK_DATA_LOSS_TIMEOUT

    attr_reader :cid, :source_name

    # TODO
    def inspect(full = false)
      attrs = full ? instance_variables : (instance_variables - [:@rx_data])
      attributes_as_nice_string = attrs.collect { |name|
        if instance_variable_defined?(name)
          "#{name}: #{instance_variable_get(name)}"
        end
      }.compact.join(", ")
      super().gsub(/\s*\>$/, " #{attributes_as_nice_string}>")
    end

    PORT = "5568" # ACN_SDT_MULTICAST_PORT
    NETMASK = "255.255.0.0"
    attr_reader :sequences
    def up_sequence(uni = 1)
      @sequences[uni] ||= 1
      current = @sequences[uni].clone
      @sequences[uni] = (@sequences[uni] % 255 + 1)
      current
    end
    attr_reader   :rx_data, :local_ip, :netmask, :broadcast_ip, :port

    def initialize(options = {})
      # raise '11'
      # puts 'options.inspect'
      # puts self.inspect
      # puts options.inspect
      @cid      = options && options[:cid] || UUIDTools::UUID.md5_create(UUIDTools::UUID_DNS_NAMESPACE, "redrocks.pro")
      @source_name = "test" * 15
      @port     = options && options[:port] || PORT
      @network  = options && options[:network] || "0.0.0.0" #"239.255.0.1" #"2.0.0.0"
      @netmask  = options && options[:netmask] || NETMASK
      @broadcast_ip = get_broadcast_ip @network, @netmask
      @local_ip = get_local_ip @network
      # puts @network
      # puts @broadcast_ip
      # puts @local_ip
      setup_connection(!options)
      @rx_data = Hash.new {|h, i| h[i] = Array.new(512, 0) }
      @nodes = {}
      @callbacks = {}
      @sequences = []
      unless @local_ip == @network
        @nodes['me'] = Node.new @network
      end
    end

    def process_events(type = nil)
      begin
        puts 'process_events inner'
        while (data, sender = @udp.recvfrom_nonblock(65535, exception: false))[0] do
        # while (data = @udp.recvfrom(65535))[0] do
          # puts 'process_rx_data'
          # puts data.inspect
          # # raise "1`111"
          
          if(data != :wait_readable)
            # puts "data.inspect"
            # puts data.inspect
            # puts sender.inspect
            data = process_rx_data(data, sender)
            puts data.inspect
            # puts 'process_rx_data after '
            return data
          end
          # process_rx_data(*data)
        end
      # rescue
      #   # puts 'no data to process!'
      #   # no data to process!
      #   return nil
      ensure
        # retry
      end
    end

    # send an Sacn packet for a specific universe
    # FIXME: make this able to unicast via a node instance method
    def send_update(uni, channels, offset = 0, limit = channels.length) #channels.length-offset)
      puts "send new sacn data"
      puts channels
      puts offset
      puts limit
      # raise "1"
      packet = Packet::Data.new(self)
      puts packet.inspect
      packet.init
      puts packet.inspect
      rx_data[uni][offset...offset+channels.length] = channels
      channels = rx_data[uni][offset...offset+limit]
      # limit = channels.length+offset # TODO: limit as 512
      packet.universe = uni
      packet.prop_values_count = limit
      # packet.start_code = offset # TODO
      # packet.first_addr = offset # TODO
      packet.channels = channels
      # puts "packet.inspect"
      # puts packet.inspect
      # raise packet.channels.inspect
      transmit packet, @nodes['me'] 
    end

    # # send an ArtPoll packet
    # # normal process_events calls later will then collect the results in @nodes
    # def poll_nodes
    #   # clear any list of nodes we already know about and start fresh
    #   @nodes.clear
    #   transmit Packet::Poll.new
    # end

    def nodes
      @nodes.values
    end

    def node(ip)
      @nodes[ip]
    end

    def on(name, &block)
      (@callbacks[name] ||= []) << block
    end
    def off(name)
      @callbacks[name]&.shift
    end

    def transmit(packet, node=nil)
      if node.nil?
        # puts 'packet.pack.inspect'
        # puts 'packet.pack.inspect'
        # puts 'packet.pack.inspect'
        # puts 'packet.pack.inspect'
        # puts 'packet.pack.inspect'
        # puts 'packet.pack.inspect'
        # puts 'packet.pack.inspect'
        # puts 'packet.pack.inspect'
        # puts packet.pack.inspect
        # raise @broadcast_ip.to_s
        @udp_bcast.send packet.pack, 0, @broadcast_ip, @port
        # @udp_bcast.send packet.pack, 0, "192.168.0.255", @port
      else
        # raise node.ip.inspect
        @udp.send packet.pack, 0, node.ip, @port
      end
    end

    # def reconnect(ip, netmask)
    #   @local_ip = ip
    #   @netmask = netmask
    #   @network = (IPAddr.new(@local_ip) & IPAddr.new(@netmask)).to_s
    #   @broadcast_ip = get_broadcast_ip @network, @netmask
    #   poll_nodes
    # end
    
    def process_data data, sender
      # puts 'process_data'
      # puts data.inspect
      process_rx_data data, sender
    end

    private

    def callback(name, *args)
      methods = @callbacks[name]
      methods.map { |m| m.call(*args) } if methods
    end

    # given a network, finds the local interface IP that would be used to reach it
    def get_local_ip(network)
      # puts 'Socket.ip_address_list'
      # puts Socket.ip_address_list.inspect
      # raise '111'
      #TODO: Socket.ip_address_list
      UDPSocket.open do |sock|
        sock.connect network, 1
        sock.addr.last
      end
    end

    # given a network, returns the broadcast IP
    def get_broadcast_ip(network, mask)
      (IPAddr.new(network) | ~IPAddr.new(mask)).to_s
    end

    def process_rx_data data, sender
      # raise "22222"
      packet = Packet.load(data, sender)
      callback_data = {
        sender: sender,
        packet: packet
      }
      case packet
      when Packet::Data
        # puts "data packet"
        # puts packet.inspect
        callback :data, callback_data
      when Packet::Sync
        # puts "sync packet"
        # puts packet.inspect
        callback :sync, callback_data
      when Packet::UniverseDiscovery
        # puts "universe_discovery packet"
        # puts packet.inspect
        callback :universe_discovery, callback_data

      when Packet::Base
        puts "packet - #{packet.inspect}"
      when nil
        puts "unknown packet. class not found"
      else
        puts "some shit happens"
      end
      callback(:message, callback_data) if packet
    end

    def setup_connection(only_bcast = false)
      unless only_bcast
        @udp = UDPSocket.new
        puts @port
        puts @udp.bind "0.0.0.0", @port rescue false
        # puts @udp.bind @local_ip, @port# rescue false
      end
      @udp_bcast = UDPSocket.new
      @udp_bcast.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    end

  end

end
