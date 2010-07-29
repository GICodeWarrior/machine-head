class MachineHead::Status
  attr_reader :channel, :lock, :signal_strength, :signal_quality,
              :symbol_quality, :raw_bitrate, :net_packetrate

  def initialize(status_text)
    @channel, @lock, @signal_strength, @signal_quality,
        @symbol_quality, @raw_bitrate,
        @net_packetrate = status_text.split.map{|i| i.split('=').last}
  end
end
