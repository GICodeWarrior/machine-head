class MachineHead::Device
  attr_reader :id, :tuners

  TOOL_PATH = '/usr/bin/hdhomerun_config'

  def initialize(id='FFFFFFFF')
    @id = id

    @tuners = [Tuner.new(self, 0), Tuner.new(self, 1)].freeze
  end

  def get(command)
    `#{TOOL_PATH} #{id} get #{command}`
  end

  def set(command, data)
    `#{TOOL_PATH} #{id} set #{command} #{data}`
  end

  %w(model features version copyright debug).each do |method|
    define_method method do
      get "/sys/#{method}"
    end
  end

  def self.discover
    devices = []

    `#{TOOL_PATH} discover`.each_line do |line|
      device = line.match(/^hdhomerun device ([0-9A-F]{8}) found/)
      devices << self.new(device[1]) if device
    end

    devices
  end
end
