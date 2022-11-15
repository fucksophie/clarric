class PacketParser
  def initialize(packet)
      @packet = packet
      @id = 0
  end

  def readByte()
      val = @packet.get_value(:U8, @id)
      @id += 1
      return val
  end

  def readSByte()
      val = @packet.get_value(:S8, @id)
      @id += 1
      return val
  end

  def readShort()
      val = @packet.get_value(:S16, @id)
      @id += 2
      return val
  end

  def readInt()
      val = @packet.get_value(:S32, @id)
      @id += 4
      return val
  end

  def readString()
      string = @packet.get_string(@id, 64)
      @id += 64
      return string.strip!
  end

  def readIoBuffer()
      x = @packet.slice(@id, 1024)
      @id += 1024
      return x
  end
end

class PacketDefs
  def self.spawn(player, id, tp)
    tp.write((PacketWrite.new).writeByte(0x07)
      .writeSByte(-1)
      .writeString(player.username)
      .writeShort(player.pos.x)
      .writeShort(player.pos.y)
      .writeShort(player.pos.z)
      .writeByte(0)
      .writeByte(0))
  end
end

class PacketWrite
  def initialize(size = 4096)
    @packet = IO::Buffer.new(size)
    @id = 0
  end

  def writeByte(value)
    @packet.set_value(:U8, @id, value)
    @id += 1
    return self
  end

  def writeSByte(value)
    @packet.set_value(:S8, @id, value)
    @id += 1
    return self
  end

  def writeShort(value)
    @packet.set_value(:S16, @id, value)
    @id += 2
    return self
  end

  def writeInt(value)
    @packet.set_value(:S32, @id, value)
    @id += 4
    return self
  end

  def writeString(value)
    for x in 1..63 do
      if value[x].nil?
        value[x] = " "
      end
    end

    @packet.set_string(value, @id)
    @id += 64
    return self
  end

  def writeBuffer(buffer) ## TODO: this function makes two buffers and it kinda sucks tbh
    if buffer.is_a?(String)
      buffer = IO::Buffer.for(buffer)
    end

    yay = IO::Buffer.new(1024)
    yay.copy(buffer, 0)

    @packet.copy(yay, @id)
    @id += 1024
    return self
  end

  def extract()
    return @packet.slice(0, @id).get_string
  end
end
