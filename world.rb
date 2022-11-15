require "zlib"
require 'stringio'

class World
  attr_accessor :name

  def initialize(name, size)
    @name = name
    @size = size

    sizeInBytes = (@size.x * @size.y * @size.z);

    @buffer = IO::Buffer.new(4 + sizeInBytes);
    @buffer.set_value(:S32, 0, sizeInBytes)

    yMiddle = (@size.y/2)-1

    for x in 0..@size.x-1 do
      for y in 0..yMiddle do
        for z in 0..@size.z-1 do
          type = 1
          if y == yMiddle
            type = 2
          end

          setBlock(Position.new(x, y, z), type)
        end
      end
    end

    load()
  end

  def setBlock(pos, type)
    @buffer.set_value(:S8, posToBuf(pos), type);
  end

  def posToBuf(pos)
    return 4 + pos.x + @size.z * (pos.z + @size.x * pos.y);
  end

  def getSpawn()
    return Position.new(
      (@size.x / 2).floor() * 32,
      (@size.y / 2).floor() * 32 + 32,
      (@size.z / 2).floor() * 32,
    )
  end

  def sendPackets(player)
    player.write((PacketWrite.new).writeByte(0x02))

    player.pos = getSpawn()

    io = StringIO.new(Zlib.gzip(@buffer.get_string))

    until io.eof?
      chunk = io.read(1024)

      player.write((PacketWrite.new)
        .writeByte(0x03)
        .writeShort(chunk.length)
        .writeBuffer(chunk)
        .writeByte(1)
      )
    end

    player.write((PacketWrite.new).writeByte(0x04).writeShort(@size.x).writeShort(@size.y).writeShort(@size.z))

    PacketDefs.spawn(player, -1, player);
  end

  def save()
    # this one entities done
  end

  def load()
    # this one entities done
  end
end
