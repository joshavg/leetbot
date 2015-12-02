# encoding: utf-8

require_relative 'IRCResponseParser'

def assert(bool, watt)
  puts "================= " + watt unless bool
end

parser = IRCResponseParser.new ':leetbot!userleetbot@i.love.debian.org MODE targetleetbot :+i'
puts parser.parts
assert parser.parts[:nick] == 'leetbot', 'nick'
assert parser.parts[:user] == 'userleetbot', 'user'
assert parser.parts[:server] == 'i.love.debian.org', 'server'
assert parser.parts[:cmd] == 'MODE', 'cmd'
assert parser.parts[:target] == 'targetleetbot', 'target'
assert parser.parts[:payload] == '+i', 'payload'
assert parser.parts[:unparseable] == nil, 'unparseable'
puts

parser = IRCResponseParser.new ':leetbot!userleetbot@i.love.debian.org JOIN :#bots'
puts parser.parts
assert parser.parts[:nick] == 'leetbot', 'nick'
assert parser.parts[:user] == 'userleetbot', 'user'
assert parser.parts[:server] == 'i.love.debian.org', 'server'
assert parser.parts[:cmd] == 'JOIN', 'cmd'
assert parser.parts[:target] == nil, 'target'
assert parser.parts[:payload] == '#bots', 'payload'
assert parser.parts[:unparseable] == nil, 'unparseable'
puts

parser = IRCResponseParser.new ':hybrid7.debian.local 372 leetbot :- -- Aurélien GÉRÔME <ag@roxor.cx>'
puts parser.parts
assert parser.parts[:server] == 'hybrid7.debian.local', 'server'
assert parser.parts[:cmd] == '372', 'cmd'
assert parser.parts[:target] == 'leetbot', 'target'
assert parser.parts[:payload] == '- -- Aurélien GÉRÔME <ag@roxor.cx>', 'payload'
assert parser.parts[:unparseable] == nil, 'unparseable'
puts

parser = IRCResponseParser.new ':hybrid7.debian.local 376 leetbot :End of /MOTD command.'
puts parser.parts
assert parser.parts[:server] == 'hybrid7.debian.local', 'server'
assert parser.parts[:cmd] == '376', 'cmd'
assert parser.parts[:target] == 'leetbot', 'target'
assert parser.parts[:payload] == 'End of /MOTD command.', 'payload'
assert parser.parts[:unparseable] == nil, 'unparseable'
puts

parser = IRCResponseParser.new ':hybrid7.debian.local NOTICE AUTH :*** No Ident response'
puts parser.parts
assert parser.parts[:server] == 'hybrid7.debian.local', 'server'
assert parser.parts[:cmd] == 'NOTICE', 'cmd'
assert parser.parts[:target] == 'AUTH', 'target'
assert parser.parts[:payload] == '*** No Ident response', 'payload'
assert parser.parts[:unparseable] == nil, 'unparseable'
puts

parser = IRCResponseParser.new ':hybrid7.debian.local MODE #bots +nt'
puts parser.parts
assert parser.parts[:server] == 'hybrid7.debian.local', 'server'
assert parser.parts[:cmd] == 'MODE', 'cmd'
assert parser.parts[:target] == '#bots', 'target'
assert parser.parts[:payload] == '+nt', 'payload'
assert parser.parts[:unparseable] == nil, 'unparseable'
puts

parser = IRCResponseParser.new ':hybrid8.debian.local NOTICE AUTH :*** Looking up your hostname...'
puts parser.parts
assert parser.parts[:server] == 'hybrid8.debian.local', 'server'
assert parser.parts[:cmd] == 'NOTICE', 'cmd'
assert parser.parts[:target] == 'AUTH', 'target'
assert parser.parts[:payload] == '*** Looking up your hostname...', 'payload'
assert parser.parts[:unparseable] == nil, 'unparseable'
puts

parser = IRCResponseParser.new ':hybrid8.debian.local 004 leetbot hybrid8.debian.local hybrid-1:8.1.17.dfsg.1-1 DFGHRSWabcdefgijklnorsuwxyz bciklmnoprstveIMORS bkloveIh'
puts parser.parts
assert parser.parts[:server] == 'hybrid8.debian.local', 'server'
assert parser.parts[:cmd] == '004', 'cmd'
assert parser.parts[:target] == 'leetbot', 'target'
assert parser.parts[:server_name] == 'hybrid8.debian.local', 'server_name'
assert parser.parts[:server_version] == 'hybrid-1:8.1.17.dfsg.1-1', 'server_version'
assert parser.parts[:user_modes] == 'DFGHRSWabcdefgijklnorsuwxyz', 'user_modes'
assert parser.parts[:channel_modes] == 'bciklmnoprstveIMORS', 'channel_modes'
assert parser.parts[:unparseable] == 'bkloveIh', 'unparseable'
puts

parser = IRCResponseParser.new ':hybrid8.debian.local 391 leetbot hybrid8.debian.local :Thursday February 5 2015 -- 19:23:53 +01:00'
puts parser.parts
assert parser.parts[:server] == 'hybrid8.debian.local', 'server'
assert parser.parts[:cmd] == '391', 'cmd'
assert parser.parts[:target] == 'leetbot', 'target'
assert parser.parts[:server_name] == 'hybrid8.debian.local', 'server_name'
assert parser.parts[:payload] == 'Thursday February 5 2015 -- 19:23:53 +01:00', 'payload'
assert parser.parts[:unparseable] == nil, 'unparseable'
puts

#parser = IRCResponseParser.new 'port80a.se.quakenet.org 391 leetbot port80a.se.quakenet.org 1449057761 3 :Wednesday December 2 2015 -- 13:02 +01:00'
#puts parser.parts
#assert parser.parts[:server] == 'port80a.se.quakenet.org', 'server'
#assert parser.parts[:cmd] == '391', 'cmd'
#assert parser.parts[:target] == 'leetbot', 'target'
#assert parser.parts[:server_name] == 'port80a.se.quakenet.org', 'server_name'
#assert parser.parts[:payload] == 'Thursday February 5 2015 -- 19:23:53 +01:00', 'payload'
#assert parser.parts[:unparseable] == nil, 'unparseable'
#puts

parser = IRCResponseParser.new 'PING : payload '
puts parser.parts
assert parser.parts[:payload] == 'payload', 'payload'
assert parser.parts[:cmd] == 'PING', 'cmd'
