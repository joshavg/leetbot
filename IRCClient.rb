# encoding: utf-8

require 'socket'
require 'logger'
require 'date'

require_relative 'IRCResponseParser'

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

      if parsed[:cmd] == '376' then
        @listeners.each { |l|
          l.connected(self) if l.respond_to? 'connected'
        }
      else
        @listeners.each { |l|
          l.accept(parsed, line, self) if l.respond_to? 'accept'
        }
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
    parser = IRCResponseParser.new line
    @@logger.debug parser.parts
    parser.parts
  end
end
