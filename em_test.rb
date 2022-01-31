#!/usr/bin/ruby

$:.unshift File.dirname(__FILE__) + '/lib'
# require 'em/pure_ruby'
require 'eventmachine'
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




trap(:INT) { puts "int"; EM.stop }
trap(:TERM){ puts "term"; EM.stop }


# @sacn = Sacn::IO.new(false)
# @sacn.on :poll do |data|
#   puts "Sacn OpPoll"# - #{data[:packet].inspect} (#{data.inspect})"
# end
# @sacn.on :dmx do |data|
#   puts "Sacn DMX - #{data[:packet].sequence}"# - #{data[:packet].inspect} (#{data.inspect})"
# end
# @sacn.on :message do |data|
#   puts "Sacn msg - #{data[:packet] && data[:packet].opcode.to_s(16)}"
# end
# step = 0
EM.run do
  Sacn::EMServer.test_me do |s|
    s.sacn.off :message
    s.sacn.on :message do |data|
      puts "msg"
    end
  end
  # EM::open_datagram_socket('192.168.0.203', Sacn::IO::PORT, nil) do |s|
  #   puts s.instance_variable_set(:@sacn, @sacn)
  #   def s.receive_data data
  #     # puts 'receive_data'
  #     sender = Socket.unpack_sockaddr_in(get_peername)
  #     #TODO: sender_addrinfo and EM get_peername
  #     sender = ["AF_INET", sender[0], sender[1], sender[1]] 
  #     @sacn.process_data(data, sender)
  #     # EM.stop
  #   end
  # end

  # EM.add_periodic_timer(0.5) {
  #   step += 10
  #   @sacn.send_update 0, [func1(step),func2(step),func3(step), func1(step),func2(step),func3(step)], 0
  # }
  # EM::open_datagram_socket('127.0.0.1', Sacn::IO::PORT) do |c|
  #   c.send_datagram 'hello', '192.168.0.255', Sacn::IO::PORT
  # end
end