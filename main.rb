require_relative 'IRCClient'
require_relative 'Leetwriter'

server = ARGV[0]
port = ARGV[1]

channels = ARGV.last(ARGV.length - 2)
channels.map! { |c| "##{c}" }

c = IRCClient.new channels

w = Leetwriter.new
c.add_listener w

c.connect server, port
