require_relative "base"

module Sacn
  module Packet
    class UniverseDiscovery < Base
    end
  end
end
require_relative "universe_discovery_packet/framing_layer"
require_relative "universe_discovery_packet/universe_discovery_layer"

module Sacn
  module Packet
    class UniverseDiscovery

      VECTOR = 0x0000_0008 #VECTOR_ROOT_E131_EXTENDED
      #TIMEOUT = 10.seconds # E131_E131_UNIVERSE_DISCOVERY_INTERVAL
      
      def pack(data = "")
        puts "universe_discovery pack"
        # puts data.inspect
        defined?(super) ? super(data) : data
      end

      prepend RootLayer # prepend|extend|include
      prepend FramingLayer # prepend|extend|include
      prepend UniverseDiscoveryLayer # prepend|extend|include

      def init(options = {})
        @root_vector = options[:vector] || VECTOR
      end

      

      # https://tsp.esta.org/tsp/documents/docs/ANSI_E1-31-2018.pdf#page=44
      def self.test_packet
        test_packet = self.new

        test_packet.preamble_size = 0x0010
        test_packet.postamble_size = 0x0000
        test_packet.ack_packet_id = [0x41,0x53,0x43,0x2d,0x45,0x31,0x2e,0x31,0x37,0x00,0x00,0x00]
        test_packet.parse_root_flength(0x7021)
        test_packet.root_vector = 0x00000008
        test_packet.cid = UUIDTools::UUID.parse_int 0xef_07_c8_dd_00_64_44_01_a3_a2_45_9e_f8_e6_14_3e

        test_packet.parse_framing_flength(0x700b)
        test_packet.framing_vector = 0x00000001
        test_packet.source_name = "TESTTESTTEST"
        test_packet.reserved = 0

        test_packet.parse_universe_discovery_flength(0x700b)
        test_packet.universe_discovery_vector = 0x00000001
        test_packet.page = 1
        test_packet.last_page = 1

        puts 'test_packet.inspect'
        puts test_packet.inspect
        puts 'test_packet.valid?'
        puts test_packet.valid?
        puts 'test_packet.pack'
        puts pack = test_packet.pack
        puts 'self.unpack pack'
        puts test_packet2 = self.unpack(pack)
        puts 'test_packet2.valid?'
        puts test_packet2.valid?
        puts 'test_packet == test_packet2'
        puts test_packet == test_packet2
        puts 'test_packet2 == test_packet'
        puts test_packet2 == test_packet
        puts 'test_packet eq test_packet2'
        puts test_packet.eql? test_packet2

        return test_packet, test_packet2
        
      end
      
    end
  end
end