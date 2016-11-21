# encoding: utf-8

require_relative 'IRCResponseParser2'

def assert(bool, watt)
  puts "================= " + watt unless bool
end

parser = IRCResponseParser2.new ':leetbot!userleetbot@i.love.debian.org MODE targetleetbot :+i'
puts parser.parts
assert parser.parts[:nick] == 'leetbot', 'nick'
assert parser.parts[:user] == 'userleetbot', 'user'
assert parser.parts[:server] == 'i.love.debian.org', 'server'
assert parser.parts[:cmd] == 'MODE', 'cmd'
assert parser.parts[:target] == 'targetleetbot', 'target'
assert parser.parts[:payload] == '+i', 'payload'
puts

parser = IRCResponseParser2.new ':leetbot!userleetbot@i.love.debian.org JOIN :#bots'
puts parser.parts
assert parser.parts[:nick] == 'leetbot', 'nick'
assert parser.parts[:user] == 'userleetbot', 'user'
assert parser.parts[:server] == 'i.love.debian.org', 'server'
assert parser.parts[:cmd] == 'JOIN', 'cmd'
assert parser.parts[:payload] == '#bots', 'payload'
puts

parser = IRCResponseParser2.new ':hybrid7.debian.local 372 leetbot :- -- Aurélien GÉRÔME <ag@roxor.cx>'
puts parser.parts
assert parser.parts[:server] == 'hybrid7.debian.local', 'server'
assert parser.parts[:cmd] == '372', 'cmd'
assert parser.parts[:target] == 'leetbot', 'target'
assert parser.parts[:payload] == '- -- Aurélien GÉRÔME <ag@roxor.cx>', 'payload'
puts

parser = IRCResponseParser2.new ':hybrid7.debian.local 376 leetbot :End of /MOTD command.'
puts parser.parts
assert parser.parts[:server] == 'hybrid7.debian.local', 'server'
assert parser.parts[:cmd] == '376', 'cmd'
assert parser.parts[:target] == 'leetbot', 'target'
assert parser.parts[:payload] == 'End of /MOTD command.', 'payload'
puts

parser = IRCResponseParser2.new ':hybrid7.debian.local NOTICE AUTH :*** No Ident response'
puts parser.parts
assert parser.parts[:server] == 'hybrid7.debian.local', 'server'
assert parser.parts[:cmd] == 'NOTICE', 'cmd'
assert parser.parts[:target] == 'AUTH', 'target'
assert parser.parts[:payload] == '*** No Ident response', 'payload'
puts

parser = IRCResponseParser2.new ':hybrid7.debian.local MODE #bots +nt'
puts parser.parts
assert parser.parts[:server] == 'hybrid7.debian.local', 'server'
assert parser.parts[:cmd] == 'MODE', 'cmd'
assert parser.parts[:target] == '#bots', 'target'
assert parser.parts[:meta] == ['+nt'], 'payload'
puts

parser = IRCResponseParser2.new ':hybrid8.debian.local NOTICE AUTH :*** Looking up your hostname...'
puts parser.parts
assert parser.parts[:server] == 'hybrid8.debian.local', 'server'
assert parser.parts[:cmd] == 'NOTICE', 'cmd'
assert parser.parts[:target] == 'AUTH', 'target'
assert parser.parts[:payload] == '*** Looking up your hostname...', 'payload'
puts

parser = IRCResponseParser2.new ':hybrid8.debian.local 004 leetbot hybrid8.debian.local hybrid-1:8.1.17.dfsg.1-1 DFGHRSWabcdefgijklnorsuwxyz bciklmnoprstveIMORS bkloveIh'
puts parser.parts
assert parser.parts[:server] == 'hybrid8.debian.local', 'server'
assert parser.parts[:cmd] == '004', 'cmd'
assert parser.parts[:target] == 'leetbot', 'target'
assert parser.parts[:meta] == ['hybrid8.debian.local', 'hybrid-1:8.1.17.dfsg.1-1', 'DFGHRSWabcdefgijklnorsuwxyz', 'bciklmnoprstveIMORS', 'bkloveIh'], 'meta'
assert parser.parts[:payload] == nil, 'payload'
puts

parser = IRCResponseParser2.new ':hybrid8.debian.local 391 leetbot hybrid8.debian.local :Thursday February 5 2015 -- 19:23:53 +01:00'
puts parser.parts
assert parser.parts[:server] == 'hybrid8.debian.local', 'server'
assert parser.parts[:cmd] == '391', 'cmd'
assert parser.parts[:target] == 'leetbot', 'target'
assert parser.parts[:payload] == 'Thursday February 5 2015 -- 19:23:53 +01:00', 'payload'
assert parser.parts[:meta] == ['hybrid8.debian.local'], 'meta'
puts

parser = IRCResponseParser2.new 'port80a.se.quakenet.org 391 leetbot port80a.se.quakenet.org 1449057761 3 :Wednesday December 2 2015 -- 13:02 +01:00'
puts parser.parts
assert parser.parts[:server] == 'port80a.se.quakenet.org', 'server'
assert parser.parts[:cmd] == '391', 'cmd'
assert parser.parts[:target] == 'leetbot', 'target'
assert parser.parts[:payload] == 'Wednesday December 2 2015 -- 13:02 +01:00', 'payload'
assert parser.parts[:meta] == ['port80a.se.quakenet.org', '1449057761', '3'], 'unparseable'
puts

parser = IRCResponseParser2.new 'PING : payload '
puts parser.parts
assert parser.parts[:payload] == ' payload', 'payload'
assert parser.parts[:cmd] == 'PING', 'cmd'
puts

parser = IRCResponseParser2.new ':Grace!~Grace@c-67-174-76-52.hsd1.va.comcast.net PRIVMSG #bots :Hello leetbot1, The resources you need to change anything in your life are within you right now. Any pattern of emotion or behavior that is continually :reinforced will become an automatic and conditioned response.'
puts parser.parts
assert parser.parts[:nick] == 'Grace', 'nick'
assert parser.parts[:user] == '~Grace', 'user'
assert parser.parts[:server] == 'c-67-174-76-52.hsd1.va.comcast.net', 'server'
assert parser.parts[:cmd] == 'PRIVMSG', 'cmd'
assert parser.parts[:target] == '#bots', 'target'
assert parser.parts[:payload] == 'Hello leetbot1, The resources you need to change anything in your life are within you right now. Any pattern of emotion or behavior that is continually :reinforced will become an automatic and conditioned response.', 'payload'
puts
