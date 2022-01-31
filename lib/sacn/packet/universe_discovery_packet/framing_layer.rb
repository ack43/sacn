module Sacn
  module Packet
    class UniverseDiscovery
      module FramingLayer
        
        # https://tsp.esta.org/tsp/documents/docs/E1-31-2016.pdf#page=21
        # https://tsp.esta.org/tsp/documents/docs/ANSI_E1-31-2018.pdf#page=21
        def self.prepended(base)
          puts "FRAME prepended"
          base.attr_accessor :framing_flags, :framing_length, :framing_vector, :source_name, :reserved
        end

        FRAME_VECTOR = 0x0000_0002 # VECTOR_E131_EXTENDED_DISCOVERY
        FRAMING_FLAGS = 0x7

        FRAMING_LAYER_SIZE = 2+4+64+2 # n l> Z64 n
        FULL_FRAMING_LAYER_SIZE = FRAMING_LAYER_SIZE
        DATA_OFFSET = FULL_FRAMING_LAYER_SIZE-RootLayer::FULL_ROOT_LAYER_SIZE

        def ==(other_packet)
          puts '==(other); data; frame(uni_discovery)'
          ret = super and 
            self.framing_flags == other_packet.framing_flags and 
            self.framing_length == other_packet.framing_length and 
            self.framing_vector == other_packet.framing_vector and 
            self.source_name == other_packet.source_name and 
            self.reserved == other_packet.reserved
          ret
        end

        def init(options = {})
          super
          @framing_flags = FRAMING_FLAGS
          @framing_vector = FRAME_VECTOR
          @source_name = @io&.source_name || options[:source_name] || "test"
          @reserved = 0
        end

        def frame_valid?(_data = nil)
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
          @framing_length = FRAMING_LAYER_SIZE + data.length
          
          puts framing_flength, @framing_vector, @source_name, @reserved
          # raise "1111"
          mydata = [framing_flength, @framing_vector, @source_name, @reserved].flatten.pack("n l> Z64 n")
          #               n               l>               Z64         n      
          puts mydata.inspect
          defined?(super) ? super(mydata + data) : mydata + data
        end

        # def unpack(data)
        #   puts "frame_unpack"
        #   puts data.inspect
        #   super(data[FRAMING_LAYER_SIZE-FULL_ROOT_LAYER_SIZE..-1]) if defined?(super)
        #   # data = data[38..-1]
        #   framing_flength, @framing_vector, @universe, @reserved = data.unpack("n l> Z64 n")
        #   puts 'valid?'
        #   puts frame_valid?
        #   parse_framing_flength(framing_flength)
        # end
        def unpack(data)
          puts "frame_unpack2"
          data = super if defined?(super)
          
          framing_flength, @framing_vector, @universe, @reserved = data.unpack("n l> Z64 n")
          
          parse_framing_flength(framing_flength)
          return data[DATA_OFFSET..-1]
          # return self
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