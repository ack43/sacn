module Sacn
  module Packet
    class Sync
      module FramingLayer
        
        # https://tsp.esta.org/tsp/documents/docs/E1-31-2016.pdf#page=29
        # https://tsp.esta.org/tsp/documents/docs/ANSI_E1-31-2018.pdf#page=29
        def self.prepended(base)
          # puts "FRAME prepended"
          base.attr_accessor :framing_flags, :framing_length, :framing_vector, :sequence, :universe, :reserved
        end

        FRAME_VECTOR = 0x0000_0001 #VECTOR_E131_EXTENDED_SYNCHRONIZATION
        FRAMING_FLAGS = 0x7

        FRAMING_LAYER_SIZE = 2+4+1+2+2 # "n l> C n n"
        FULL_FRAMING_LAYER_SIZE = FRAMING_LAYER_SIZE
        DATA_OFFSET = FULL_FRAMING_LAYER_SIZE-RootLayer::FULL_ROOT_LAYER_SIZE

        def ==(other_packet)
          # puts '==(other); data; frame(sync)'
          ret = super and 
            self.framing_flags == other_packet.framing_flags and 
            self.framing_length == other_packet.framing_length and 
            self.framing_vector == other_packet.framing_vector and 
            self.sequence == other_packet.sequence and 
            self.first_addr == other_packet.first_addr and 
            self.universe == other_packet.universe and 
            self.reserved == other_packet.reserved
          ret
        end

        def init(options = {})
          # puts "FRAME INIT"
          super
          @framing_flags = FRAMING_FLAGS
          @framing_vector = FRAME_VECTOR
          @universe = options[:universe]
          @reserved = 0
          # @sequence = options[:sequence] || @io&.up_sequence(@universe) || 1
        end

        def frame_valid?(_data = nil)
          # puts "frame_valid?"
          # puts  @framing_vector
          # puts FRAME_VECTOR
          valid = @framing_vector == FRAME_VECTOR
          # valid && (defined?(super) ? super : true)
        end
        def valid?(data = nil)
          if !data and defined?(super) 
            frame_valid? and super
          else
            frame_valid?(data)
          end
        end

        def pack(data = "")
          # puts "frame_pack"
          # puts data.inspect
          @sequence = @io&.up_sequence(@universe) || 1
          # layer_length = 2+4+64+1+2+1+1+2
          @framing_length = FRAMING_LAYER_SIZE + data.length
          # puts '@framing_length'
          # puts layer_length
          # puts @framing_length
          mydata = [framing_flength, @framing_vector, @sequence, @universe, @reserved].flatten.pack("n l> C n n")
          #               n               l               C           n         n      
          # puts mydata.inspect
          defined?(super) ? super(mydata + data) : mydata + data
        end


        # def unpack(data)
        #   puts "frame_unpack"
        #   puts data.inspect
        #   super(data[FRAMING_LAYER_SIZE-FULL_ROOT_LAYER_SIZE..-1]) if defined?(super)
        #   # data = data[38..-1]
        #   framing_flength, @framing_vector, @sequence, @universe, @reserved = data.unpack("n l> C n n")
        #   puts 'valid?'
        #   puts frame_valid?
        #   parse_framing_flength(framing_flength)
        # end

        def unpack(data)
          data = super if defined?(super)
          
          framing_flength, @framing_vector, @sequence, @universe, @reserved = data.unpack("n l> Z64 C n C c n")
          
          parse_framing_flength(framing_flength)
          # return data[DATA_OFFSET..-1]
          return self
        end


        def framing_flength
          ((@framing_flags & 0x0f) << (4+8) | (@framing_length & 0x0fff))
        end
  
        def parse_framing_flength(framing_flength)
          @framing_flags = (framing_flength >> (4+8)) & 0x0f
          @framing_length = framing_flength & 0x0fff # (framing_flength << 4) >> 4
          self
        end

      end
    end
  end
end