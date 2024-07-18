require "paquito"
require "lz4-ruby"
require "benchmark"

module Coder
  MSGPACK = Paquito::SingleBytePrefixVersionWithStringBypass.new(
    0,
    {
      0 => Paquito.chain(
        Paquito::CodecFactory.build(
          [Symbol, Time, DateTime, Date, BigDecimal, Set],
          # freeze: true, # disable freeze for now as some codepath expect mutable objects
        ),
        # Only compress for payload larger than 100,000 bytes
        Paquito::ConditionalCompressor.new(Paquito::TranslateErrors.new(LZ4), 100000),
      ),
    },
    Paquito::ConditionalCompressor.new(Paquito::TranslateErrors.new(LZ4), 100000),
  )
  MARSHAL_PREFIX = "\x04\x08".b.freeze
  class << self
    def load(payload)
      if payload.start_with?(MARSHAL_PREFIX)
        begin
          Marshal.load(payload)
        rescue ArgumentError => error
          Config.notify_exception(error)
          nil
        end
      else
        begin
          MSGPACK.load(payload)
        rescue Paquito::Error => error
          Config.notify_exception(error)
          nil
        end
      end
    end

    if Config.test_environment?
      def dump(object)
        MSGPACK.dump(object) # don't rescue the error in CI and test env
      end
    else
      def dump(object)
        MSGPACK.dump(object)
      rescue Paquito::Error => error
        Config.notify_exception(error)
        nil
      end
    end
  end
end

def benchmark_coder
  message = "hello, world"

  Benchmark.bm do |x|
    x.report("Encoding:") do
      @encoded_message = Coder.dump(message)
    end

    x.report("Decoding:") do
      @decoded_message = Coder.load(@encoded_message)
    end
  end

  puts "Original message: #{message}"
  puts "Encoded message: #{@encoded_message}"
  puts "Decoded message: #{@decoded_message}"
end

benchmark_coder
