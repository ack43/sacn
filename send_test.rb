#!/usr/bin/ruby

$:.unshift File.dirname(__FILE__) + '/lib'
require 'sacn'


def func1(step) 
  step %= 255
  step
end
def func2(step) 
  step %= 255
  step += 100
  step % 255
end
def func3(step) 
  step %= 255
  step *= -1
  step % 255
end

# temporary test script used to test things as they're being built
# will be replaced with real tests :)
sacn = Sacn::IO.new network: "192.168.0.255", netmask: "255.255.255.0"
# sacn = Sacn::IO.new network: "192.168.0.203", netmask: "255.255.255.0"
# sacn = Sacn::IO.new network: "239.255.0.4", netmask: "255.255.255.0"
# sacn = Sacn::IO.new network: "127.0.0.1", netmask: "255.255.255.0"
puts sacn.nodes

sacn.on :message do |data|
  puts "Sacn msg - #{data.inspect}"
end
puts "send random"
# sacn.send_update 0, [100], 5
# sleep 0.5 
# sacn.send_update 1, [1], 5
# sleep 0.5 
# sacn.send_update 2, [2], 5
# sleep 0.5 
# sacn.send_update 3, [3], 5
# sleep 0.5 
# sacn.send_update 4, [4], 5
# sleep 0.5 
# sacn.send_update 5, [5], 5
# sleep 0.5 

# sacn.send_update 0, [200], 5,20
# sleep 0.5 
# sacn.send_update 1, [10], 5,25
# sleep 0.5 
# sacn.send_update 2, [20], 5,30
# sleep 0.5 
# sacn.send_update 3, [30], 5,35
# sleep 0.5 
# sacn.send_update 4, [40], 5,40
# sleep 0.5 
# sacn.send_update 5, [50], 5,45

while true
  sleep 0.1 
  sacn.send_update 2, [Random.rand(256)], Random.rand(512)
end

sleep 0.5 