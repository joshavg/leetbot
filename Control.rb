require 'logger'

require_relative 'IRCMessage'

class Control
  @@logger = Logger.new STDOUT
  @authorized
  def initialize
    @authorized = []
  end

  def accept(parsed, line, client)
    # {:nick=>"josha", :user=>"~jgizycki", :server=>"192.168.115.109", :cmd=>"PRIVMSG", :target=>"leetbot", :payload=>"sad"}
    if parsed[:cmd] == "PRIVMSG"
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

    case parsed[:payload]
    when "authorized" then
      write_authorized parsed, client
    end
  end

  def request_authorization(parsed, client)
    client.write IRCMessage.privmsg(parsed[:nick], "authorize first")
  end

  def write_authorized(parsed, client)
    @authorized.each { |u|
      client.write IRCMessage.privmsg(parsed[:nick], u)
    }
  end
end
