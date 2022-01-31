module Sacn
  module Packet
    class UniverseDiscovery
      module UniverseDiscoveryLayer
        
        # https://tsp.esta.org/tsp/documents/docs/E1-31-2016.pdf#page=21
        # https://tsp.esta.org/tsp/documents/docs/ANSI_E1-31-2018.pdf#page=21
        def self.prepended(base)
          puts "FRAME prepended"
          base.attr_accessor :universe_discovery_flags, :universe_discovery_length, :universe_discovery_vector, :page, :last_page, :list_of_universes
        end

        VECTOR_UNIVERSE_DISCOVERY_UNIVERSE_LIST = 0x0000_0001
        UNIVERSE_DISCOVERY_FLAGS = 0x7

        UNIVERSE_DISCOVERY_LAYER_SIZE = 2+4+1+1
        FULL_UNIVERSE_DISCOVERY_LAYER_SIZE = UNIVERSE_DISCOVERY_LAYER_SIZE
        DATA_OFFSET = FULL_UNIVERSE_DISCOVERY_LAYER_SIZE-FramingLayer::FULL_FRAMING_LAYER_SIZE

        E131_DISCOVERY_UNIVERSE = 64214

        def ==(other_packet)
          puts '==(other); data; uni_discovery(uni_discovery)'
          ret = super and 
            self.universe_discovery_flags == other_packet.universe_discovery_flags and 
            self.universe_discovery_length == other_packet.universe_discovery_length and 
            self.universe_discovery_vector == other_packet.universe_discovery_vector and 
            self.page == other_packet.page and 
            self.last_page == other_packet.last_page and 
            self.list_of_universes == other_packet.list_of_universes
          ret
        end

        def init(options = {})
          super
          @universe_discovery_flags = UNIVERSE_DISCOVERY_FLAGS
          @universe_discovery_vector = VECTOR_UNIVERSE_DISCOVERY_UNIVERSE_LIST
          @page = 0
          @last_page = 0
          @list_of_universes = []
        end

        def universe_discovery_valid?(_data = nil)
          valid = @universe_discovery_vector == VECTOR_UNIVERSE_DISCOVERY_UNIVERSE_LIST
        end
        def valid?(data = nil)
          if !data and defined?(super) 
            universe_discovery_valid? and super
          else
            universe_discovery_valid?(data)
          end
        end

        def pack(data = "")
          puts "universe_discovery_pack2"
          puts data.inspect
          @universe_discovery_length = UNIVERSE_DISCOVERY_LAYER_SIZE + (@list_of_universes&.length || 0) + (data&.length || 0)
          # puts '@universe_discovery_length'
          # puts layer_length
          # puts @universe_discovery_length
          mydata = [universe_discovery_flength, @universe_discovery_vector, @page, @last_page].flatten.pack("n l> C C")
          #               n                                l                    C        C
          mydata += @list_of_universes.pack("C#{@list_of_universes.length}") if @list_of_universes && @list_of_universes.length > 0
          puts mydata.inspect
          defined?(super) ? super(mydata + data) : mydata + data
        end

        # def unpack(data)
        #   puts "universe_discovery_unpack"
        #   puts data.inspect
        #   super(data[UNIVERSE_DISCOVERY_LAYER_SIZE-FramingLayer::FULL_FRAMING_LAYER_SIZE..-1]) if defined?(super)
        #   # data = data[38..-1]
        #   universe_discovery_flength, @universe_discovery_vector, @page, @last_page = data.unpack("n l> C C")
        #   puts 'valid?'
        #   puts frame_valid?
        #   parse_universe_discovery_flength(universe_discovery_flength)
        # end
        def unpack(data)
          puts "universe_discovery_unpack2"
          data = super if defined?(super)
          
          universe_discovery_flength, @universe_discovery_vector, @page, @last_page = data.unpack("n l> C C")
          
          parse_universe_discovery_flength(universe_discovery_flength)
          return self
        end


        def universe_discovery_flength
          puts '@universe_discovery_flags.inspect '
          puts @universe_discovery_flags.inspect 
          ((@universe_discovery_flags & 0x0f) << (4+8) | (@universe_discovery_length & 0x0fff))
        end
  
        def parse_universe_discovery_flength(universe_discovery_flength)
          @universe_discovery_flags = (universe_discovery_flength >> (4+8)) & 0x0f
          @universe_discovery_length = universe_discovery_flength & 0x0fff # (universe_discovery_flength << 4) >> 4
          self
        end

      end
    end
  end
end