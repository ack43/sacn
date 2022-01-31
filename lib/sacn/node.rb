module Sacn
  class Node

    attr_accessor :ip, :mac, :firmware_version, :mfg, :uni, :subuni, :shortname, :longname, :numports, :swin, :swout
    def initialize(ip, options = {})
      if ip.is_a?(Hash)
        options = ip
      else
        @ip = ip
      end
      @ip = options.fetch(:ip, @ip)
      @mac = options.fetch(:mac, nil)
      @firmware_version = options.fetch(:firmware_version, nil)
      @mfg = options.fetch(:mfg, nil)
      @uni = options.fetch(:uni, nil)
      @subuni = options.fetch(:subuni, nil)
      @shortname = options.fetch(:shortname, nil)
      @longname = options.fetch(:longname, nil)
      @numports = options.fetch(:numports, nil)
      @swin = options.fetch(:swin, nil)
      @swout = options.fetch(:swout, nil)
    end

    def ==(other)
      puts '==(other); node'
      fields = [:ip, :mac, :firmware_version, :mfg, :uni, :subuni, :shortname, :longname, :numports, :swin, :swout]
      fields.all?{|field| other.respond_to?(field) && send(field) == other.send(field)}
    end

  end
end
