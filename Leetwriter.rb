require 'logger'
require 'date'

class Leetwriter

    @@logger = Logger.new STDOUT

    def initialize
        Thread.abort_on_exception = true
    end

    def accept(parsed, line, client)
        if parsed[:cmd] == "391" then
            # contains something like 19:23:53 +01:00
            timevalue = parsed[:payload] == nil ? parsed[:params] : parsed[:payload]
            strtime = timevalue.split(" -- ").last
            @@logger.debug("got #{strtime.strip} as string time")
            
            # crappy irc rfc does not say which time format will be delivered,
            # so hard parsing will be the weapon of choice
            dateTimeParts = strtime.split(" ")
            datePart = dateTimeParts[0]
            #timePart = dateTimeParts[1]
            hour = datePart.split(":").first
            minute = datePart.split(":")[1]
            
            @@logger.debug("hour is #{hour}, minute is #{minute}")
            
            if hour == "13" and minute == "37" then
                client.broadcast "leet"
            end
        end
    end
    
    def connected(client)
        Thread.new do
            while true do
                client.write "TIME"
                sleep 10
            end
        end
    end
end
