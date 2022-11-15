class Player
  def initialize(socket, username, mppass)
    @socket = socket;
    @username = username;
    @mppass = mppass;

    buff = (PacketWrite.new).writeByte(0x00)
      .writeByte(0x07)
      .writeString("Clarric welcome #{@username}")
      .writeString("written by ~yourfriend")
      .writeByte(0x64)
      .extract();

    @socket.send(buff, 0)
    @socket.send((PacketWrite.new).writeByte(0x02).extract(), 0)
  end
end
