require 'uuidtools'
# require 'macaddr'

module Sacn
  module Packet
    module RootLayer

      # https://tsp.esta.org/tsp/documents/docs/E1-31-2016.pdf#page=23
      PREAMBLE_SIZE = 0x0010
      POSTAMBLE_SIZE = 0x0000
      ROOT_FLAGS = 0x70
      ACN_PACKET_ID = [0x41, 0x53, 0x43, 0x2d, 0x45, 0x31, 0x2e, 0x31, 0x37, 0x00, 0x00, 0x00]

      ROOT_LAYER_SIZE = 2+4+16 # 2+2+ACN_PACKET_ID.length+2+4+16
      FULL_ROOT_LAYER_SIZE = 2+2+ACN_PACKET_ID.length+2+4+16
      DATA_OFFSET = FULL_ROOT_LAYER_SIZE

      # VECTOR_ROOT_E131_DATA = 0x0000_0004
      # VECTOR_ROOT_E131_EXTENDED = 0x0000_0008

      def self.extended(base)
        puts "ROOT extended"
        # base.attr_accessor :preamble_size, :postamble_size, :ack_packet_id, :root_flags, :root_length, :root_vector, :cid
      end
      attr_accessor :preamble_size, :postamble_size, :ack_packet_id, :root_flags, :root_length, :root_vector, :cid


      def ==(other_packet)
        puts '==(other); root'
        #ret =  super and 
        # puts self
        # puts other_packet
        ret = self.preamble_size == other_packet.preamble_size and 
          self.postamble_size == other_packet.postamble_size and 
          self.ack_packet_id == other_packet.ack_packet_id and 
          self.root_flags == other_packet.root_flags and 
          self.preamble_size == other_packet.root_length and 
          self.root_vector == other_packet.root_vector and 
          self.cid == other_packet.cid 
        # puts 'root def ==(other_packet)'
        # puts ret
        ret
      end
      # def eql?(other_packet)
      #   puts 'root def eql?(other_packet)'
      #   # super and
      #   puts ret = self.preamble_size == other_packet.preamble_size and 
      #     self.postamble_size == other_packet.postamble_size and 
      #     self.ack_packet_id == other_packet.ack_packet_id and 
      #     self.root_flags == other_packet.root_flags and 
      #     self.preamble_size == other_packet.root_length and 
      #     self.root_vector == other_packet.root_vector and 
      #     self.cid == other_packet.cid 
      #   ret
      # end

      def pack_cid
        pack = []
        cid_int = @cid.to_i
        16.times do |i|
          pack << ((cid_int >> (i*8)) & 0xff)
        end
        pack.reverse
      end
      # def unpack_cid(cid_arr)
      #   _cid_arr = cid_arr#.reverse
      #   unpack_cid = 0
      #   16.times do |i|
      #     unpack_cid += (_cid_arr[i] << (i*8))
      #   end
      #   unpack_cid
      # end

      def init(options = {})
        puts "ROOT INIT"
        super if defined?(super)
        @preamble_size = PREAMBLE_SIZE
        @postamble_size = POSTAMBLE_SIZE
        @ack_packet_id = ACN_PACKET_ID
        @root_flags = ROOT_FLAGS
        @cid = options[:cid] || io&.cid || UUIDTools::UUID.md5_create(UUIDTools::UUID_DNS_NAMESPACE, "redrocks.pro") # UUIDTools::UUID.random_create
      end

      # def unpack(data, single = false)
      #   puts "root_unpack"
      #   @preamble_size, @postamble_size = data.unpack("n n")
      #   @ack_packet_id = data.unpack("@#{2+2} c#{ACN_PACKET_ID.length}")
      #   root_flength, @root_vector = data.unpack("@#{2+2+ACN_PACKET_ID.length} n l>")
        
      #   @cid = data.unpack("@#{2+2+ACN_PACKET_ID.length+2+4} c16")
      #   cid_offset = 2+2+ACN_PACKET_ID.length+2+4
      #   @cid = UUIDTools::UUID.parse_raw data[cid_offset...cid_offset+16]
        
      #   parse_root_flength(root_flength)
      #   super(data[DATA_OFFSET..-1]) if !single and defined?(super)
      # end

      def unpack(data, single = false)
        data = super if !single && defined?(super)
        # puts "root_unpack2"

        @preamble_size, @postamble_size = data.unpack("n n")
        @ack_packet_id = data.unpack("@#{2+2} c#{ACN_PACKET_ID.length}")
        root_flength, @root_vector = data.unpack("@#{2+2+ACN_PACKET_ID.length} n l>")

        @cid = data.unpack("@#{2+2+ACN_PACKET_ID.length+2+4} c16")
        cid_offset = 2+2+ACN_PACKET_ID.length+2+4
        @cid = UUIDTools::UUID.parse_raw data[cid_offset...cid_offset+16]

        parse_root_flength(root_flength)

        return (single ? self : data[DATA_OFFSET..-1]) # to FRAME Layer
      end



      def pack(data = "")
        puts "root_pack"
        @root_length = ROOT_LAYER_SIZE + data.length
        
        mydata = [@preamble_size, @postamble_size, @ack_packet_id,          root_flength, @root_vector, pack_cid].flatten.pack("n n c#{ACN_PACKET_ID.length} n l> c16")
        #             n                 n          c#{ACN_PACKET_ID.length}   n               l           c16
        
        defined?(super) ? super(mydata + data) : mydata + data
      end



      def root_valid?(data = nil)
        return (unpack(data, true) && valid?), @root_vector if data
        
        valid = @preamble_size == PREAMBLE_SIZE and
          @postamble_size == POSTAMBLE_SIZE and
          @ack_packet_id == ACN_PACKET_ID 
        # valid && (defined?(super) ? super : true)
      end
      def valid?(data = nil)
        if !data and defined?(super) 
          root_valid? && super
        else
          root_valid?(data)
        end
      end
      def self.valid?(data)
        preamble_size, postamble_size = data.unpack("n n")
        ack_packet_id = data.unpack("@#{2+2} C#{ACN_PACKET_ID.length}")
        _root_flength, root_vector = data.unpack("@#{2+2+ACN_PACKET_ID.length} n L>")
        
        valid = (preamble_size == PREAMBLE_SIZE) and
          (postamble_size == POSTAMBLE_SIZE) and
          (ack_packet_id == ACN_PACKET_ID) 
        
          return valid, root_vector
      end


      def root_flength
        ((@root_flags.to_i & 0x0f) << (8+4) | (@root_length.to_i & 0x0fff)) # 0x70 << 8 or 0x7 << 4+8 => 0x7xxx
      end

      def parse_root_flength(root_flength)
        @root_flags = (root_flength >> (4+8)) & 0x0f
        @root_length = root_flength & 0x0fff # (root_flength << 4) >> 4
        self
      end

    end
  end
end