class MachineHead::Tuner
  attr_reader :id, :device

  def initialize(device, id)
    @device = device
    @id = id
  end

  def get(command)
    device.get("/tuner#{id}/#{command}")
  end

  def set(command, data)
    device.set("/tuner#{id}/#{command}", data)
  end

  %w(channel channelmap filter program target).each do |method|
    define_method method do
      get method
    end

    define_method "#{method}=" do |data|
      set method, data
    end
  end

  def streaminfo
    get 'streaminfo'
  end

  def status
    Status.new(get('status'))
  end
end
