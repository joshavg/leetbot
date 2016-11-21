require 'logger'

require_relative 'IRCMessage'

class Renamer
  @@logger = Logger.new STDOUT
  @authorized
  @tries
  
  def initialize
    @authorized = []
    @tries = 0
  end

  def accept(parsed, line, client)
    if parsed[:cmd] == '433'
      react parsed, client
    end
  end

  private

  def react(parsed, client)
    @tries += 1
    name = client.nick + @tries.to_s
    client.write IRCMessage.nick name
  end
end
