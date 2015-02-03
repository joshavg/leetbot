require 'socket'
require 'logger'

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

            if parsed[:code] == 376 then
                @listeners.each { |l| l.connected }
            else
                @listeners.each { |l| l.accept parsed, line }
            end
        end
    end

    def accept(parsed, line)
        if parsed[:command] == 'PING' then
            write "PONG #{parsed[:value]}"
        end
    end

    def connected
        @channels.each { |c| write "JOIN " + c }
    end

    private
    def parse_line(line)
        # :nick!~realname@server command channel :msg
        # :leetbot!leetbot@i.love.debian.org MODE leetbot :+i
        # :leetbot!leetbot@i.love.debian.org JOIN :#bots
        messageMatcher = /:(\S+)!(\S+)@(\S+) (\S+) (\S+)?( )?:(.*)/.match line
        # :server code nick server :msg
        #:hybrid7.debian.local 372 leetbot :- -- Aurélien GÉRÔME <ag@roxor.cx>
        #:hybrid7.debian.local 376 leetbot :End of /MOTD command.
        systemNumericMatcher = /:(\S+) ([0-9]+) (\S+) (\S+)?( )?:?(.*)/.match line
        #:hybrid7.debian.local NOTICE AUTH :*** No Ident response
        systemCharMatcher = /:(\S+) (\S+) (\S+) :(.*)/.match line
        #:hybrid7.debian.local MODE #bots +nt
        channelMatcher = /:(\S+) (\S+) (#\S+) (\S+)/.match line
        # P[I|O]NG :payload
        pingMatcher = /(P[I|O]NG) :(.*)/.match line
        
        parsed = nil
        if messageMatcher then
            parsed = {
                :nick => messageMatcher[1],
                :user => messageMatcher[2],
                :server => messageMatcher[3],
                :cmd => messageMatcher[4],
                :target => messageMatcher[5],
                :payload => messageMatcher[7]
            }
        elsif channelMatcher then
            parsed = {
                :server => channelMatcher[1],
                :cmd => channelMatcher[2],
                :channel => channelMatcher[3],
                :payload => channelMatcher[4]   
            }
        elsif systemNumericMatcher then
            parsed = {
                :server => systemNumericMatcher[1],
                :code => systemNumericMatcher[2].to_i,
                :nick => systemNumericMatcher[3],
                :ident => systemNumericMatcher[4],
                :payload => systemNumericMatcher[6]
            }
        elsif systemCharMatcher then
            parsed = {
                :server => systemCharMatcher[1],
                :type => systemCharMatcher[2],
                :cmd => systemCharMatcher[3],
                :payload => systemCharMatcher[4]
            }
        elsif pingMatcher then
            parsed = {
                :cmd => pingMatcher[1],
                :payload => pingMatcher[2]
            }
        end
        
        return parsed
    end
end

class Leetwriter

    @@logger = Logger.new STDOUT

    def initialize client
        @client = client
        Thread.abort_on_exception = true
    end

    def accept(parsed, line)
        
    end
    
    def connected
        Thread.new do
            while true do
                @client.write "TIME"
                sleep 10
            end
        end
    end
end

server = ARGV[0]
port = ARGV[1]

channels = ARGV.last(ARGV.length - 2)
channels.map! { |c| "##{c}" }

c = IRCClient.new channels

w = Leetwriter.new c
c.add_listener w

c.connect server, port
