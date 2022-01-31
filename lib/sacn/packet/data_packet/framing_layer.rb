module Sacn
  module Packet
    class Data
      module FramingLayer
        
        # https://tsp.esta.org/tsp/documents/docs/E1-31-2016.pdf#page=25
        # https://tsp.esta.org/tsp/documents/docs/ANSI_E1-31-2018.pdf#page=25
        def self.prepended(base)
          puts "FRAME prepended"
          base.attr_accessor :framing_flags, :framing_length, :framing_vector, :source_name, :priority, :sync_addr, :sequence, :options, :universe
        end
        # attr_accessor :framing_flags, :framing_length, :framing_vector, :source_name, :priority, :sequence, :options, :universe

        def ==(other_packet)
          puts '==(other); data; frame'
          ret = super and 
            self.framing_flags == other_packet.framing_flags and 
            self.framing_length == other_packet.framing_length and 
            self.framing_vector == other_packet.framing_vector and 
            self.source_name == other_packet.source_name and 
            self.priority == other_packet.priority and 
            self.sync_addr == other_packet.sync_addr and 
            self.sequence == other_packet.sequence and 
            self.options == other_packet.options and
            self.universe == other_packet.universe
          # puts 'frame def ==(other_packet)'
          # puts ret
          ret
        end
        # def eql?(other_packet)
        #   puts 'frame def eql?other_packet)'
        #   puts ret = super and 
        #     self.framing_flags == other_packet.framing_flags and 
        #     self.framing_length == other_packet.framing_length and 
        #     self.framing_vector == other_packet.framing_vector and 
        #     self.source_name == other_packet.source_name and 
        #     self.priority == other_packet.priority and 
        #     self.sync_addr == other_packet.sync_addr and 
        #     self.sequence == other_packet.sequence and 
        #     self.options == other_packet.options and
        #     self.universe == other_packet.universe
        #   ret
        # end

        FRAME_VECTOR = 0x0000_0002 # VECTOR_E131_DATA_PACKET
        FRAMING_FLAGS = 0x7

        FRAMING_LAYER_SIZE = 2+4+64+1+2+1+1+2
        FULL_FRAMING_LAYER_SIZE = FRAMING_LAYER_SIZE
        DATA_OFFSET = FULL_FRAMING_LAYER_SIZE#FULL_FRAMING_LAYER_SIZE-RootLayer::FULL_ROOT_LAYER_SIZE

        def init(options = {})
          puts "FRAME INIT"
          super
          @framing_flags = FRAMING_FLAGS
          @framing_vector = FRAME_VECTOR
          @source_name = @io&.source_name || options[:source_name] || "test"
          @priority = options[:priority] || 100
          @options = options[:options] || 0x00 # 0b0111_0000
          @sync_addr = options[:sync_addr] || 0 # 10000 # TODO
          @universe = options[:universe] || 0
          # @sequence = options[:sequence] || @io&.up_sequence(@universe) || 1
        end

        def frame_valid?(_data = nil)
          valid = @framing_vector == FRAME_VECTOR and 
          @universe >= 1 && @universe <= 63999
        end
        def valid?(data = nil)
          if !data and defined?(super) 
            frame_valid? and super
          else
            frame_valid?(data)
          end
        end


        def pack(data = "")
          puts "frame_pack"

          @sequence = @io&.up_sequence(@universe) || 1

          @framing_length = FRAMING_LAYER_SIZE + data.length

          mydata = [framing_flength, @framing_vector, @source_name, priority, @sync_addr, @sequence, @options, @universe].flatten.pack("n l> Z64 C n C C n")
          #               n               l               Z64           C         n         C           c         n

          defined?(super) ? super(mydata + data) : mydata + data
        end


        # def unpack(data)
        #   super(data[DATA_OFFSET..-1]) if defined?(super)

        #   framing_flength, @framing_vector, @source_name, @priority, @sync_addr, @sequence, @options, @universe = data.unpack("n l> Z64 C n C C n")

        #   parse_framing_flength(framing_flength)
        # end

        def unpack(data)
          data = super if defined?(super)
          
          framing_flength, @framing_vector, @source_name, @priority, @sync_addr, @sequence, @options, @universe = data.unpack("n l> Z64 C n C C n")

          parse_framing_flength(framing_flength)
          return data[DATA_OFFSET..-1] # to DMP Layer
        end


        def framing_flength
          ((@framing_flags & 0x0f) << (4+8) | (@framing_length & 0x0fff))
        end
  
        def parse_framing_flength(framing_flength)
          @framing_flags = (framing_flength >> (4+8)) & 0x0f
          @framing_length = framing_flength & 0x0fff # (framing_flength << 4) >> 4
          self
        end

        def preview_data; @options & 0b0100_0000; end
        def stream_terminated; @options & 0b0010_0000; end
        def force_sync; @options & 0b001_0000; end
      end
    end
  end
end