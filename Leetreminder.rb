require 'logger'
require 'date'

class Leetreminder

  @@logger = Logger.new STDOUT
  @@target_hour = 13
  @@target_minute = 32
  
  @received_date
  @leeted
  @next_request

  def initialize
    Thread.abort_on_exception = true
    @leeted = false
  end

  def accept(parsed, line, client)
    if parsed[:cmd] == "391" then
      # example from quakenet
      # Tuesday November 20 2016 -- 09:46 +01:00
      
      parts = line.split " -- "
      if parts.length != 2 then
        return
      end
      
      # https://ruby-doc.org/stdlib-2.1.1/libdoc/date/rdoc/DateTime.html#method-i-strftime
      @received_date = DateTime::strptime(parsed[:payload], "%A %B %d %Y -- %H:%M %z").new_offset DateTime.now.offset
      
      @@logger.debug("got #{parsed[:payload]} as string time")
      @@logger.debug("parsed date is #{@received_date}")
      
      hour = @received_date.hour
      minute = @received_date.minute
      @@logger.debug("hour is #{hour}, minute is #{minute}")

      if hour == @@target_hour and minute == @@target_minute then
        client.broadcast "leet in 5 minutes"
        @leeted = true
      end
    elsif parsed[:cmd] == "PRIVMSG" and parsed[:target] == client.nick then
      case
        when parsed[:payload] == "interval?" then
          client.write IRCMessage.privmsg(parsed[:nick], @next_request.to_s)
      end
    end
  end

  def connected(client)
    Thread.new do
      loop do
        client.write "TIME"

        # wait til the server time is returned and parsed
        while @received_date.nil?
          sleep 1
        end
        
        now = @received_date
        target = DateTime.new(now.year, now.month, now.mday, @@target_hour, @@target_minute, 0, now.strftime("%z"))
        
        @received_date = nil
        
        # in range for small interval
        if now.hour == @@target_hour and now.minute.between?(@@target_minute - 5, @@target_minute) and !@leeted then
          @next_request = now + 10 / 86400
          sleep 10
        else
          target = now < target ? target : target.next_day
          
          diff = (target - now).to_f
          # wait about five minutes less than necessary to get to the exact
          # target date to catch the smaller interval
          wait = diff - (4.9 * 60) / 86400
          @next_request = now + wait
          
          sleep wait * 86400
        end

        @leeted = false
      end
    end
  end
end
