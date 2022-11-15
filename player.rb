class Player
  attr_accessor :pos, :server, :username, :world, :id, :rotation

  def initialize(socket, username, mppass, server)
    @socket = socket;
    @server = server;
    @pos = Position.new(0, 0, 0)
    @rotation = Rotation.new

    @id = -1;
    usedIds = []

    for x in @server.clients
      if x.player
        if x.player.id
          usedIds.append(x.player.id)
        end
      end
    end

    for i in 0..@server.max
      unless usedIds.include?(i)
        @id = i
      end
    end

    unless @id == -1
      @username = username;
      @mppass = mppass;
      @world = "main"

      buff = (PacketWrite.new).writeByte(0x00)
        .writeByte(0x07)
        .writeString("Clarric welcome #{@username}")
        .writeString("written by ~yourfriend")
        .writeByte(0x64)
        .extract();

      @socket.send(buff, 0)
      sendToWorld()


    end
  end

  def sendToWorld()
      @server.findWorld(@world).sendPackets(self)

      @server.broadcastExcept(self) do |e|
        e.write((PacketWrite.new).writeByte(0x0c).writeSByte(@id))
      end

      @server.broadcastExcept(self) do |e|
        PacketDefs.spawn(self, self.id, e) end

      @server.broadcastExcept(self) do |e|
        PacketDefs.spawn(e, e.id, self) end

  end
  def write(pw)
    @socket.send(pw.extract(), 0)
  end
end
