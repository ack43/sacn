require_relative "base"

module Sacn
  module Packet
    class Data < Base
    end
  end
end
require_relative "data_packet/framing_layer"
require_relative "data_packet/dmp_layer"

module Sacn
  module Packet
    class Data

      VECTOR = 0x0000_0004 # VECTOR_ROOT_E131_DATA
      
      def pack(data = "")
        puts "data pack"
        defined?(super) ? super(data) : data
      end

      prepend RootLayer # prepend|extend|include
      prepend FramingLayer # prepend|extend|include
      prepend DMPLayer # prepend|extend|include

      def init(options = {})
        @root_vector = options[:vector] || VECTOR
      end

      
      # https://tsp.esta.org/tsp/documents/docs/ANSI_E1-31-2018.pdf#page=43
      def self.test_packet
        test_packet = self.new

        test_packet.preamble_size = 0x0010
        test_packet.postamble_size = 0x0000
        test_packet.ack_packet_id = [0x41,0x53,0x43,0x2d,0x45,0x31,0x2e,0x31,0x37,0x00,0x00,0x00]
        test_packet.parse_root_flength(0x726e)
        test_packet.root_vector = 0x00000004
        test_packet.cid = UUIDTools::UUID.parse_int 0xef_07_c8_dd_00_64_44_01_a3_a2_45_9e_f8_e6_14_3e
        
        test_packet.parse_framing_flength(0x7258)
        test_packet.framing_vector = 0x00000002
        test_packet.source_name = "Source_A"
        test_packet.priority = 100
        test_packet.sync_addr = 7962
        test_packet.sequence = 154
        test_packet.options = 0b0000_0000
        test_packet.universe = 1
        
        test_packet.parse_dmp_flength(0x720b)
        test_packet.dmp_vector = 0x02
        test_packet.atdt = 0xa1
        test_packet.first_addr = 0x0000
        test_packet.addr_inc = 0x0001
        test_packet.prop_values_count = 0x0201
        test_packet.start_code = 0
        test_packet.prop_values = Array.new(test_packet.prop_values_count-1) {
          Random.rand 255
        }
        test_packet.prop_values[0...5] = [0xAA, 0xAA, 0xAA, 0xAA, 0xAA]

        puts 'test_packet.valid?'
        puts test_packet.valid?
        puts 'test_packet.pack'
        puts (pack = test_packet.pack).inspect
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