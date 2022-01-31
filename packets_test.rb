#!/usr/bin/ruby

$:.unshift File.dirname(__FILE__) + '/lib'
require 'sacn'

puts ARGV.inspect
packets = if ARGV.empty?
  ['all']
else
  ARGV & ['data', 'sync', 'universe_discovery', 'all']
end
puts packets
packets.each do |klass|
  case klass.to_sym
  when :data
    puts
    puts 'Sacn::Packet::Data.test_packet'
    test_packet, test_packet2 = Sacn::Packet::Data.test_packet
    puts test_packet.inspect
    puts test_packet2.inspect
  when :sync
    puts
    puts
    puts 'Sacn::Packet::Sync.test_packet'
    test_packet, test_packet2 = Sacn::Packet::Sync.test_packet
    puts test_packet.inspect
    puts test_packet2.inspect
  when :universe_discovery
    puts
    puts
    puts 'Sacn::Packet::UniverseDiscovery.test_packet'
    test_packet, test_packet2 = Sacn::Packet::UniverseDiscovery.test_packet
    puts test_packet.inspect
    puts test_packet2.inspect
  when :all
    puts
    puts
    puts
    puts
    puts 'test all packets'
    puts 'Sacn::Packet::Data.test_packet'
    test_packet, test_packet2 = Sacn::Packet::Data.test_packet
    puts test_packet.inspect
    puts test_packet2.inspect
    puts
    puts
    puts 'Sacn::Packet::Sync.test_packet'
    test_packet, test_packet2 = Sacn::Packet::Sync.test_packet
    puts test_packet.inspect
    puts test_packet2.inspect
    puts
    puts
    puts 'Sacn::Packet::UniverseDiscovery.test_packet'
    test_packet, test_packet2 = Sacn::Packet::UniverseDiscovery.test_packet
    puts test_packet.inspect
    puts test_packet2.inspect
    puts
    puts
  end
end
    