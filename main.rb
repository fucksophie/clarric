require 'socket'
require "./packets.rb"
require "./player.rb"

$dataLengths = {0 => 130, 5 => 8 , 8 => 9, 13 => 65}

class Position
    Integer x = 0
    Integer y = 0
    Integer z = 0
end

class Client
    def initialize(socket)
        @socket = socket
        @pos = Position.new

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

                #MISSING PROPER READING!!!! ADD PROPER READING

                parser = PacketParser.new(buffer)

                if packetID == 0
                    p = parser.readByte();
                    username = parser.readString()
                    mppass = parser.readString()

                    Player.new(socket, username, mppass)
                end
            else
                puts "client closed manually"
                break
            end
        end
    end

end

server = TCPServer.new 2000

loop do
    Thread.start(server.accept) do |client|
        Client.new(client)
    end
end
