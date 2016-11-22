# :leetbot!userleetbot@i.love.debian.org MODE targetleetbot :+i
# :leetbot!userleetbot@i.love.debian.org JOIN :#bots
# :hybrid7.debian.local 372 leetbot :- -- Aurélien GÉRÔME <ag@roxor.cx>
# :hybrid7.debian.local 376 leetbot :End of /MOTD command.
# :hybrid7.debian.local NOTICE AUTH :*** No Ident response
# :hybrid7.debian.local MODE #bots +nt
# :hybrid8.debian.local NOTICE AUTH :*** Looking up your hostname...
# :hybrid8.debian.local 004 leetbot hybrid8.debian.local hybrid-1:8.1.17.dfsg.1-1 DFGHRSWabcdefgijklnorsuwxyz bciklmnoprstveIMORS bkloveIh
# :hybrid8.debian.local 391 leetbot hybrid8.debian.local :Thursday February 5 2015 -- 19:23:53 +01:00
# port80a.se.quakenet.org 391 leetbot port80a.se.quakenet.org 1449057761 3 :Wednesday December 2 2015 -- 13:02 +01:00
# PING : payload
# :Grace!~Grace@c-67-174-76-52.hsd1.va.comcast.net PRIVMSG #bots :Hello leetbot1
# :niven.freenode.net 353 leetbot1 @ #bots42 :@leetbot1

class IRCResponseParser2

  attr_reader :parts
  
  def initialize msg
    @parts = {}
    workmsg = msg
    
    if workmsg[0] != ":"
      workmsg = ":" + workmsg
    end
    
    parts = (" " + workmsg).split " :"
    if parts.length < 1 then
      return
    end
    
    if parts[2] then
      payload = workmsg.slice (3 + parts[1].length), workmsg.length
      @parts[:payload] = payload.rstrip
    end
    header = parts[1]
    
    hp = header.split(" ")
    
    is_ping = false
    # user ident
    if /^([^!]+)!([^@]+)@(.+)$/.match hp[0] then
      @parts[:nick] = $1
      @parts[:user] = $2
      @parts[:server] = $3
    else
      if hp[0] == "PING" then
        @parts[:cmd] = hp[0]
        is_ping = true
      else
        @parts[:server] = hp[0]
      end
    end
    
    if !is_ping then
      @parts[:cmd] = hp[1]
    end
    
    @parts[:target] = hp[2]
    
    if hp.length > 3 then
      @parts[:meta] = hp.last(hp.length - 3)
    end
  end

end
