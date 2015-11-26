require 'socket'
require 'logger'
require 'date'

class Object
    def is_number?
        self.to_f.to_s == self.to_s || self.to_i.to_s == self.to_s
    end
end

class IRCClient

    @@logger = Logger.new STDOUT

    public
    def initialize channels
        @@logger.debug 'init'
        @listeners = [self]
        @channels = channels
    end

    def add_listener(listener)
        @listeners.push listener
    end

    def write(msg)
        @@logger.debug "outgoing: #{msg}"
        @socket.write msg + "\r\n"
    end

    def broadcast(msg)
        @@logger.debug "broadcasting #{msg}"
        @channels.each { |c|
            write "PRIVMSG #{c} #{msg}"
        }
    end
  
    def connect(host, port = 6667)
        @socket = TCPSocket.open(host, port)
        write 'USER leetbot 0 * :leetbot'
        write 'NICK leetbot'
        
        while line = @socket.readline do
            parsed = parse_line line

            @@logger.debug "incoming: #{line.strip}"
            #@@logger.debug parsed
            
            if parsed[:cmd] == '376' then
                @listeners.each { |l| l.connected self }
            else
                @listeners.each { |l| l.accept parsed, line, self }
            end
        end
    end

    def accept(parsed, line, client)
        if parsed[:cmd] == "PING" then
            write "PONG #{parsed[:payload]}"
        end
    end

    def connected(client)
        @channels.each { |c| write "JOIN " + c }
    end

    private
    def parse_line(line)
        regexp = /^:?((?<nick>\S+)!(?<user>\S+)@)?(?<server>\S+)\s(?<cmd>\S+)\s((?<target>\S+)\s)?((?<target2>\S+)\s)?((:(?<payload>.+))|(?<params>.*))$/
        matcher = regexp.match line
        # P[I|O]NG :payload
        pingMatcher = /(?<cmd>PING) :(?<payload>.*)/.match line
        
        pingMatcher != nil ? pingMatcher : matcher
    end
end
