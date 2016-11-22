require 'logger'

require_relative 'IRCMessage'

class Control
  @@logger = Logger.new STDOUT
  @authorized

  def initialize
    @authorized = []
  end

  def accept(parsed, line, client)
    if parsed[:cmd] == "PRIVMSG" and parsed[:target] == client.nick then
      react parsed, client
    end
  end

  private

  def react(parsed, client)
    if parsed[:payload] == "authorize!"
      @authorized.push parsed[:user]
      client.write IRCMessage.privmsg(parsed[:nick], "authorized")
      return
    elsif !@authorized.include?(parsed[:user])
      request_authorization parsed, client
      return
    end

    case
      when parsed[:payload] == "authorized?" then
        write_authorized parsed, client
      when parsed[:payload] == "quit!" then
        client.quit!
      when parsed[:payload] == "listeners?" then
        write_listeners parsed, client
      when parsed[:payload].match(/join! (#[^\s]+)/) then
        join_channel client, $1
    end
  end

  def join_channel(client, channel)
    client.write IRCMessage.join(channel)
  end

  def write_listeners(parsed, client)
    client.listeners.each do |l|
      client.write IRCMessage.privmsg(parsed[:nick], l.class.name)
    end
  end

  def request_authorization(parsed, client)
    client.write IRCMessage.privmsg(parsed[:nick], "authorize first")
  end

  def write_authorized(parsed, client)
    @authorized.each do |u|
      client.write IRCMessage.privmsg(parsed[:nick], u)
    end
  end
end
