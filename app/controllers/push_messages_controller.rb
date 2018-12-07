require 'line/bot'
class PushMessagesController < ApplicationController
    before_action :authenticate_user!


    # GET /push_messages/new
    def new
    end

    # POST /push_messages
    def create
        text = params[:text]
        Channel.all.each do |channel|
            push_to_line(channel.channel_id, text)
        end
        redirect_to '/push_messages/new'
    end

    # 傳送訊息到Line
    def push_to_line(channel_id, text)
        return nil if channel_id.nil? or text.nil?

        # 設定回覆訊息
        message = {
            type: 'text',
            text: text
        }

        # 傳送訊息
        line.push_message(channel_id, message)
    end

    # Line Bot API 物件初始化
    def line
        @line ||= Line::Bot::Client.new { |config|
            config.channel_secret = '10f88109463f23cdf580ecddc364664c'
            config.channel_token = 'PJ13Or13E0TR+dy4CWR30jvA0dMNEqdRqtoB69YIrE7c8AAS0iqVZKgsxfifW4WJbzQlGZGXFKd7fekupwKWE7MikJ+fmy+sZW/30M/KOZJaP83FNSKwWSS1qforSoOhzs5cb2yKG+t1x6MduBJzLwdB04t89/1O/w1cDnyilFU='
        }
    end
end