#!/usr/bin/ruby

$:.unshift File.dirname(__FILE__) + '/lib'
require 'sacn'

# temporary test script used to test things as they're being built
# will be replaced with real tests :)
# sacn = Sacn::IO.new network: "192.168.0.255", netmask: "255.255.255.0"
# sacn = Sacn::IO.new network: "192.168.0.120", netmask: "255.255.255.0"
sacn = Sacn::IO.new network: "0.0.0.0", netmask: "255.255.255.0"

sacn.on :message do |data|
  puts "Sacn msg - #{data.inspect}"
end
step = 0
while(step += 10) do
  # sacn.send_update 0, [Random.rand(255)] if Random.rand(10) == 0
  puts 'process_events'
  sacn.process_events
  # puts 'after process_events'
  # # puts sacn.rx_data
  # #puts "Seeing #{sacn.nodes.length} node(s) on the network:"
  # #sacn.nodes.each do |node|
  # #  puts "#{node.ip}\t#{node.shortname}\t#{node.longname}"
  # #end
  # puts 'sleep'
  # sleep 0.5
end
