require 'socket'
require "./packets.rb"
require "./player.rb"
require "./world.rb"

$dataLengths = {0 => 130, 5 => 8 , 8 => 9, 13 => 65}

class Position
    attr_accessor :x,:y,:z

    def initialize(x2,y2,z2)
        @x = x2
        @y = y2
        @z = z2
    end
end

class Rotation
    attr_accessor :yaw, :pitch

    def initialize()
        @yaw = 0
        @pitch = 0
    end
end

class Client
    attr_accessor :player, :socket

    def initialize(socket, server)
        @socket = socket
        @server = server
        @player = false
    end

    def start()
        loop do
            readID = @socket.recv(1)
            if !readID.empty?
                packetID = readID.ord;

                length = $dataLengths[packetID]

                unless length
                    puts "#{packetID} unknown"
                    break
                end

                packet = ""

                packet = @socket.recv(length)
                buffer = IO::Buffer.for(packet)

                unless packet
                    puts "packet read attempt failed"
                    break
                end

                parser = PacketParser.new(buffer)

                if packetID == 0
                    p = parser.readByte();
                    username = parser.readString()
                    mppass = parser.readString()

                    @player = Player.new(@socket, username, mppass, @server)

                    for x in @server.clients # i am so smart - thanks me - wow me you are so kind
                        if x.socket != @socket && x.player.username == username
                            @player.write((PacketWrite.new).writeByte(0x0e).writeString("Your name already exists!"))
                            break
                        end
                    end

                    if @player.id == -1
                        @player.write((PacketWrite.new).writeByte(0x0e).writeString("All usable ID's have been exhausted."))
                        break
                    end
                end
            else
                puts "client closed manually"
                break
            end
        end
    end
end

class Server
    attr_accessor :clients, :worlds, :max

    def initialize(port, max)
        @server = TCPServer.new port
        @max = max

        @clients = []
        @worlds = [World.new("main", Position.new(64, 64, 64))]

        loop do
            Thread.start(@server.accept) do |client|
                puts "welcome"
                c = Client.new(client, self);
                @clients.append(c)
                c.start()

                broadcastExcept(c.player) do |e|
                    e.write((PacketWrite.new).writeByte(0x0c).writeSByte(c.player.id))
                end

                @clients.delete(c)
                puts "bye"

            end
        end
    end

    def broadcastExcept(player, &block)
        for c in @clients
            if c.player
                if c.player != player && c.player.world == player.world
                    yield c.player
            end
        end
    end

    def broadcast(writer)
        for c in @clients
        end
    end

    def findWorld(str)
        for w in @worlds do
            if w.name == str
                return w
            end
        end
    end
end

Server.new(2000, 2)
