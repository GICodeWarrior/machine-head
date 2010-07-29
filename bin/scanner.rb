#!/usr/bin/ruby

require 'timeout'
require 'rubygems'
require 'machine-head'
require 'gnuplot'

def avg(values)
  values.inject(:+) / values.size.to_f
end

def stddev(values)
  count = values.size
  mean = avg(values)

  Math.sqrt(values.inject(0){|sum, e| sum + (e - mean) ** 2} / count.to_f)
end

device = MachineHead::Device.new('FFFFFFFF')
tuner = device.tuners.last
channels = (2..69).to_a

signal_strengths = []
signal_qualities = []
symbol_qualities = []

channels.each do |channel|
  STDOUT.print "#{channel}, "
  STDOUT.flush

  tuner.channel = "8vsb:#{channel}"
  sleep 2

  signal_status = []
  begin
    timeout(10.0) do
      loop do
        signal_status << tuner.status
      end
    end
  rescue Timeout::Error
  end

  if signal_status.detect{|s| s.lock != 'none'}
    strengths = signal_status.map(&:signal_strength).map(&:to_i)
    signal_strengths << [channel, avg(strengths), stddev(strengths)]

    qualities = signal_status.map(&:signal_quality).map(&:to_i)
    signal_qualities << [channel, avg(qualities), stddev(qualities)]

    symbols = signal_status.map(&:symbol_quality).map(&:to_i)
    symbol_qualities << [channel, avg(symbols), stddev(symbols)]
  end
end

puts
puts "Locked: #{signal_strengths.map(&:first).join(', ')}"

Gnuplot.open do |gp|
  Gnuplot::Plot.new( gp ) do |plot|

    plot.title 'Signal breakdown'
    plot.ylabel '%'
    plot.xlabel 'Channel'
    plot.xrange '[0:70]'
    plot.yrange '[0:100]'
    plot.key 'outside bottom'

    labels = signal_qualities.map do |channel|
      channel = channel.dup
      channel[1] -= channel[2] + 6
      channel[2] = channel[0]

      channel
    end

    plot.data = [
      Gnuplot::DataSet.new(signal_strengths.transpose) {|ds|
        ds.with = 'yerrorbars'
        ds.title = 'Signal Strength'
        ds.linewidth = 1
      },

      Gnuplot::DataSet.new(signal_qualities.transpose) {|ds|
        ds.with = 'yerrorbars'
        ds.title = 'Signal Quality'
        ds.linewidth = 1
      },

      Gnuplot::DataSet.new(symbol_qualities.transpose) {|ds|
        ds.with = 'yerrorbars'
        ds.title = 'Symbol Quality'
        ds.linewidth = 1
      },

      Gnuplot::DataSet.new(labels.transpose) {|ds|
        ds.with = 'labels'
        ds.notitle
      }
    ]
  end
end
