require 'ipaddr'
require_relative "packet/base"

module Sacn

  class PacketFormatError < RuntimeError
  end

  module Packet

    @@types = {}

    def self.types
      @@types
    end

    def self.register(klass)
      @@types[klass.const_get('VECTOR')] = klass
    end

    def self.load(data, sender = nil)
      valid, vector = Base.valid?(data)
      raise PacketFormatError.new('Not an sAcn packet (valid)') unless valid
      klass = types[vector]
      if klass.nil?
        puts "Unknown vector 0x#{vector.to_s(16)}"
        packet = Base.new(vector)
        packet.raw_data = data
      else
        # puts "klass.unpack"
        # puts klass
        # puts data.inspect
        packet = klass.unpack(data, sender)
      end
      return packet
    end
    def self.safe_load(data, sender = nil)
      valid, vector = Base.valid?(data)
      klass = types[vector]
      if klass.nil?
        puts "Unknown vector 0x#{vector.to_s(16)}"
        packet = Base.new(vector)
        packet.raw_data = data
      else
        packet = klass.unpack(data, sender)
      end
      return packet
    end

    {
      data: 'Data',
      sync: 'Sync',
      universe_discovery: 'UniverseDiscovery'
    }.each_pair do |file,  klass|
      require_relative "packet/#{file}"
      register const_get(klass)
    end

  end
end

