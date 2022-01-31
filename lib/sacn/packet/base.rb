require_relative "root_layer"

module Sacn::Packet
  class Base

    # def ==(other_packet)
    #   puts 'def ==(other_packet)'
    #   # return super if defined?(super)
    #   return true
    # end

    # TODO
    def inspect(full = false)
      attrs = full ? instance_variables : (instance_variables - [:@prop_values, :@channels, :@data])
      attributes_as_nice_string = attrs.collect { |name|
        if instance_variable_defined?(name)
          "#{name}: #{instance_variable_get(name)}"
        end
      }.compact.join(", ")
      "#<#{self.class} #{attributes_as_nice_string}>"
    end

    def self.valid?(data = '')
      RootLayer.valid? data
    end

    attr_accessor :io
    attr_accessor :raw_data
    def initialize(io = nil)
      @io = io
    end


    attr_writer :net_info

    # def self.unpack(data, net_info = nil)
    #   p = self.new
    #   p.unpack(data)
    #   # net_info[4] = Time.now
    #   # p.net_info = net_info

    #   p
    # end
    def self.unpack(data, net_info = nil)
      p = self.new
      p.unpack(data)
      p
    end

    def pack(data = "")
      # puts "i cant pack "
      raise "super" if defined?(super)
      data
    end

    def type
      self.class.name.split('::').last
    end

    def self.test_packet
      puts self.inspect
      puts 'not implemented yet'
    end

    private

    def check_version(ver)
      raise Sacn::PacketFormatError.new("Bad protocol version #{ver}") unless ver == PROTVER
    end

  end
end
