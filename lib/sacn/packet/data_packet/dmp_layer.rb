module Sacn
  module Packet
    class Data
      module DMPLayer

        # https://tsp.esta.org/tsp/documents/docs/ANSI_E1-31-2018.pdf#page=19
        DMP_FLAGS = 0x7 # 0b0111_0000
        DMP_VECTOR = 0x02 # VECTOR_DMP_SET_PROPERTY
        ATDT = 0xa1
        FIRST_ADDR = 0x0000;
        ADDR_INC = 0x0001;

        DMP_LAYER_SIZE = 2+1+1+2+2+2+1 # n C C n n n C
        # DATA_OFFSET = 

        def init(options = {})
          # puts "DMP INIT"
          @dmp_flags = DMP_FLAGS
          @dmp_vector = DMP_VECTOR
          @atdt = ATDT
          @first_addr = FIRST_ADDR
          @addr_inc = ADDR_INC
          @prop_values_count = 1 # 513
          @start_code = 0
          @prop_values = []
          super
        end
        
        def self.prepended(base)
          # puts "DMP prepended"
          base.attr_accessor :dmp_flags, :dmp_length, :dmp_vector, :atdt, :first_addr, :addr_inc, :prop_values_count, :start_code, :prop_values
          base.attr_accessor :start_code, :data

          base.alias_method :channels, :prop_values
          base.alias_method :channels=, :prop_values=
        end
        # attr_accessor :dmp_flags, :dmp_length, :dmp_vector, :atdt, :first_addr, :addr_inc, :prop_values_count, :prop_values
        # attr_accessor :start_code, :data

        def ==(other_packet)
          # puts '==(other); data; dmp'
          ret = super and 
            self.dmp_flags == other_packet.dmp_flags and 
            self.dmp_length == other_packet.dmp_length and 
            self.dmp_vector == other_packet.dmp_vector and 
            self.atdt == other_packet.atdt and 
            self.first_addr == other_packet.first_addr and 
            self.addr_inc == other_packet.addr_inc and 
            self.prop_values_count == other_packet.prop_values_count and 
            self.prop_values == other_packet.prop_values 
          # puts 'dmp def ==(other_packet)'
          # puts ret
          ret
        end
        # def eql?(other_packet)
        #   puts 'dmp def eql?(other_packet)'
        #   puts ret = super and 
        #     self.dmp_flags == other_packet.dmp_flags and 
        #     self.dmp_length == other_packet.dmp_length and 
        #     self.dmp_vector == other_packet.dmp_vector and 
        #     self.atdt == other_packet.atdt and 
        #     self.first_addr == other_packet.first_addr and 
        #     self.addr_inc == other_packet.addr_inc and 
        #     self.prop_values_count == other_packet.prop_values_count and 
        #     self.prop_values == other_packet.prop_values 
        #   ret
        # end
        

        def dmp_valid?(_data = nil)
          valid = @dmp_vector == DMP_VECTOR and
            @atdt == ATDT and
            @first_addr == FIRST_ADDR and
            @addr_inc == ADDR_INC
        end
        def valid?(data = nil)
          if !data and defined?(super) 
              # dmp_valid? and super # TODO: double root_valid? because of include in Base
            dmp_valid?
          else
            dmp_valid?(data)
          end
        end



        def pack(data = "")
          puts "dmp_pack"
          
          @prop_values = @prop_values[0...512]
          @prop_values_count = @prop_values.count+1
          
          @dmp_length = DMP_LAYER_SIZE + @prop_values_count
          
          mydata = [dmp_flength, @dmp_vector, @atdt, @first_addr, @addr_inc, @prop_values_count, @start_code, @prop_values].flatten.pack("n C C n n n C C#{@prop_values_count-1}") 
          #               n           C         C         n           n           n                   C        C#{@prop_values_count-1}
          
          defined?(super) ? super(mydata + data) : mydata + data
        end

        # def unpack(data)
        #   dmp_flength, @dmp_vector, @atdt, @first_addr, @addr_inc, @prop_values_count, @start_code = data.unpack("n C C n n n C")
        #   # n               C         C       n             n           n                   C
        #   # @prop_values_count-=1
        #   parse_dmp_flength(dmp_flength)
        #   @data = data.unpack("@#{DMP_LAYER_SIZE}C#{@prop_values_count}")
        #   if @prop_values_count > 1 # (@prop_values_count > 0)
        #     # puts '@data.inspect1---------------------------------------------------' # TODO::::q
        #     # # puts @data.size
        #     # # puts @data.inspect
        #     # raise "111"
        #   end
        # end

        def unpack(data)
          data = super if defined?(super)
          dmp_flength, @dmp_vector, @atdt, @first_addr, @addr_inc, @prop_values_count, @start_code = data.unpack("n C C n n n C")
          # n               c         C       n             n           n                   C
          
          # @prop_values_count-=1
          parse_dmp_flength(dmp_flength)
          @prop_values = data.unpack("@#{DMP_LAYER_SIZE}C#{@prop_values_count-1}")
          if @prop_values_count > 1
            # puts '@data.inspect2---------------------------------------------------' # TODO::::q
            # # puts @data.size
            # # puts @data.inspect
            # raise "222"
          end
          self
        end


        def dmp_flength
          ((@dmp_flags & 0x0f) << (4+8) | (@dmp_length & 0x0fff))
        end

        def parse_dmp_flength(dmp_flength)
          @dmp_flags = (dmp_flength >> (4+8)) & 0x0f
          @dmp_length = dmp_flength & 0x0fff # (dmp_flength << 4) >> 4
          self
        end

      end
    end
  end
end