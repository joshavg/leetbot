class IRCMessage
  def IRCMessage.privmsg(user, msg)
    "PRIVMSG #{user} :#{msg}"
  end
end