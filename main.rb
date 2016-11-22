require_relative 'IRCClient'
require_relative 'Leetwriter'
require_relative 'Leetreminder'
require_relative 'Control'
require_relative 'Renamer'

server = ARGV[0]
port = ARGV[1]

server ||= 'irc.quakenet.org'
port ||= 6667

c = IRCClient.new

c.add_listener Control.new
# not yet working as intended, suspended
#c.add_listener Leetwriter.new
c.add_listener Renamer.new
c.add_listener Leetreminder.new

c.connect server, port
