# frozen_string_literal: true

require_relative "sacn/version"

require_relative "sacn/io"
require_relative "sacn/node"
require_relative "sacn/packet"

module Sacn
  class Error < StandardError; end
  # Your code goes here...
end


if defined?(EM) or defined?(EventMachine)
  require 'sacn/em'
end
