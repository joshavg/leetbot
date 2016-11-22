class IRCMessage
  def IRCMessage.privmsg(user, msg)
    "PRIVMSG #{user} :#{msg}"
  end
  
  def IRCMessage.nick(name)
    "NICK #{name}"
  end
  
  def IRCMessage.user(name)
    "USER #{name} 0 * :#{name}"
  end
  
  def IRCMessage.join(channel)
    "JOIN #{channel}"
  end
end
