require 'logger'
require 'date'

class Leetreminder

  @@logger = Logger.new STDOUT
  @received_hour
  @received_minute

  def initialize
    Thread.abort_on_exception = true
  end

  def accept(parsed, line, client)
    if parsed[:cmd] == "391" then
      parts = line.split " -- "
      strtime = parts.last

      # contains something like 19:23:53 +01:00
      # timevalue = parsed[:payload]
      # strtime = timevalue.split(" -- ").last
      @@logger.debug("got #{strtime.strip} as string time")

      # crappy irc rfc does not say which time format will be delivered,
      # so hard parsing will be the weapon of choice
      dateTimeParts = strtime.split(" ")
      datePart = dateTimeParts[0]
      hour = datePart.split(":").first
      minute = datePart.split(":")[1]

      @received_hour = hour.to_i
      @received_minute = minute.to_i

      @@logger.debug("hour is #{hour}, minute is #{minute}")

      if hour == "13" and minute == "32" then
        client.broadcast "leet in 5 minutes"
      end
    end
  end

  def connected(client)
    Thread.new do
      loop do
        client.write "TIME"

        # wait til the server time is returned and parsed
        while @received_hour.nil?
          sleep 1
        end

        rest_hours = 0
        if @received_hour > 13 then
          rest_hours = 13 + 24 - @received_hour
        else
          rest_hours = 13 - @received_hour
        end

        rest_minutes = 0
        if @received_minute > 32 then
          rest_minutes = 32 + 60 - @received_minute
        else
          rest_minutes = 32 - @received_minute
        end

        # amount of seconds to wait till 13:37
        wait_sec = rest_hours * 60 * 60 + rest_minutes * 60
        # subtract 4 minutes for more exact landing on 13:37
        wait_sec -= 5 * 60

        @received_hour = nil
        @received_minute = nil

        # if the wait duration is smaller than 5 minutes, wait only 30 seconds
        wait_sec = wait_sec < 5 * 60 ? 30 : wait_sec

        @@logger.debug "waiting #{wait_sec} seconds, next request on #{Time.now + wait_sec}"

        sleep wait_sec
      end
    end
  end
end
