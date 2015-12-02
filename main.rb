require_relative 'IRCClient'
require_relative 'Leetwriter'
require_relative 'Control'

server = ARGV[0]
port = ARGV[1]

channels = ARGV.last(ARGV.length - 2)
channels.map! { |c| "##{c}" }

c = IRCClient.new channels

c.add_listener Control.new
c.add_listener Leetwriter.new

c.connect server, port
