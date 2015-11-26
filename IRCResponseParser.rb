# encoding: utf-8

class IRCResponseParser
    @line
    @parts
    @user_server_regex
    @nextstep
    @verbose

    attr_reader :parts

    def initialize(line, verbose = false)
        puts line
        @verbose = verbose
        @line = line
        @parts = {}
        @user_server_regex = /^([^!]+)!([^@]+)@(.+)$/
        parse
    end

    private
    def parse
        if @line[0] == ':' then
            devline = @line.slice 1, @line.size - 1
            index = 0
            
            log
            log devline
            devline.split(' ').each do |token|
                log
                log 'step:  ' + @nextstep.to_s unless @nextstep.nil?
                log 'token: ' + token
                
                if @nextstep.nil? then
                    if @user_server_regex.match token then
                        parse_user_server_ident token
                        @nextstep = :cmd
                    else
                        @parts[:server] = token
                        @nextstep = :cmd
                    end
                else
                    case @nextstep
                        when :cmd then
                            @parts[:cmd] = token
                            if token.to_i != 0 then
                                @nextstep = :target
                            else
                                @nextstep = :switch_target_payload
                            end
                        when :switch_target_payload then
                            if token[0] == ':' then
                                rest_as_payload index
                                #@parts[:payload] = devline.slice index + 1, devline.size
                                break
                            else
                                @parts[:target] = token
                                if token.start_with? '#' then
                                    @nextstep = :payload
                                else
                                    @nextstep = :switch_target_payload
                                end
                            end
                        when :target then
                            write_part :target, token, :switch_server_name_payload
                        when :switch_server_name_payload then
                            if token[0] == ':' then
                                rest_as_payload index
                                #@parts[:payload] = devline.slice index + 1, devline.size
                                break
                            else
                                @parts[:server_name] = token
                                @nextstep = :switch_server_version_payload
                            end
                        when :server_name then
                            @parts[:server_name] = token
                            @nextstep = :switch_server_version_payload
                        when :switch_server_version_payload then
                            if token[0] == ':' then
                                rest_as_payload index
                                #@parts[:payload] = devline.slice index + 1, devline.size
                                break
                            else
                                write_part :server_version, token, :user_modes
                            end
                        when :user_modes then
                            write_part :user_modes, token, :channel_modes
                        when :channel_modes then
                            write_part :channel_modes, token, :unparseable
                        when :payload then
                            write_part :payload, token, :unparseable
                        when :params then
                            write_part :params, token, :unparseable
                        when :unparseable then
                            @parts[:unparseable] = '' if @parts[:unparseable].nil?
                            @parts[:unparseable] = (@parts[:unparseable] + "\n" + token).strip
                    end
                end
                
                index += token.size + 1
            end
        elsif @line.start_with? 'PING' then
            @parts[:cmd] = 'PING'
            @parts[:payload] = @line.split(':')[1].strip
        end

        log @parts
    end

    def parse_user_server_ident(token)
        matcher = @user_server_regex.match token
        @parts[:nick] = matcher[1]
        @parts[:user] = matcher[2]
        @parts[:server] = matcher[3]
    end

    def write_part(current, token, step)
        @parts[current] = token
        @nextstep = step
    end

    def rest_as_payload(index)
        @parts[:payload] = @line.slice index + 2, @line.size
    end

    def log(msg = '')
        puts msg if @verbose
    end

end
