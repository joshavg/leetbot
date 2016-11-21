require_relative 'IRCClient'
require_relative 'Leetwriter'
require_relative 'Control'
require_relative 'Renamer'

server = ARGV[0]
port = ARGV[1]

server ||= 'irc.freenode.org'
port ||= 6667

if ARGV.length > 2
    channels = ARGV.last(ARGV.length - 2)
    channels.map! { |c| "##{c}" }
else
    channels = ['#bots42']
end

c = IRCClient.new channels

c.add_listener Control.new
# not yet working as intended, suspended
#c.add_listener Leetwriter.new
c.add_listener Renamer.new

c.connect server, port
