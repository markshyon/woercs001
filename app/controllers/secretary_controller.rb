require 'line/bot'
class SecretaryController < ApplicationController
    protect_from_forgery with: :null_session

    def webhook

        # 學說話
        reply_text = learn(channel_id, received_text)

        # 設定回覆訊息
        reply_text = keyword_reply(channel_id, received_text) if reply_text.nil?

        # 推齊
        reply_text = echo2(channel_id, received_text) if reply_text.nil?

        # 記錄對話
        save_to_received(channel_id, received_text)
        save_to_reply(channel_id, reply_text)

        # 傳送訊息到Line
        response = reply_to_line(reply_text)
    
        # 回應 200
        head :ok
    end

    # 頻道ID
    def channel_id
        source = params['events'][0]['source']
        source['groupId'] || source['roomId'] || source['userId']
    end

    # 儲存對話
    def save_to_received(channel_id, received_text)
        return if received_text.nil?
        Received.create(channel_id: channel_id, text:received_text)
    end

    # 儲存回應
    def save_to_reply(channel_id, reply_text)
        return if reply_text.nil?
        Reply.create(channel_id: channel_id, text:reply_text)
    end

    # 推齊
    def echo2(channel_id, received_text)
        # 沒人講過就不回應
        recent_received_texts = Received.where(channel_id: channel_id).last(5)&.pluck(:text)
        return nil unless received_text.in? recent_received_texts

        #如果上一句重複，就不回應
        last_reply_text = Reply.where(channel_id: channel_id).last&.text
        return nil if last_reply_text == received_text

        received_text
    end

    # 取得對方說的話
    def received_text
        message = params['events'][0]['message']
        message['text'] unless message.nil?
    end

    # 學說話區塊
    def learn(channel_id, received_text)
        # 如果開頭不是 老賈學說話; 就跳出
        return nil unless received_text[0..5] == '老賈學說話;'

        received_text = received_text[6..-1]
        semicolon_index = received_text.index(';')

        # 找不到分號就跳出
        return nil if semicolon_index.nil?

        keyword = received_text[0..semicolon_index-1]
        message = received_text[semicolon_index+1..-1]

        KeywordMapping.create(channel_id: channel_id, keyword: keyword, message: message)
        '報告~是!'
    end

    # 關鍵字回覆
    def keyword_reply(channel_id, received_text)
        message = KeywordMapping.where(channel_id: channel_id, keyword: received_text).last&.message
        return message unless message.nil?
        KeywordMapping.where(keyword: received_text).last&.message
    end

    # 傳送訊息到Line
    def reply_to_line(reply_text)
        return nil if reply_text.nil?

        # 取得reply token
        reply_token = params['events'][0]['replyToken']

        # 設定回覆訊息
        message = {
            type: 'text',
            text: reply_text
        }

        # 傳送訊息
        line.reply_message(reply_token, message)
    end

    # Line Bot API 物件初始化
    def line
        @line ||= Line::Bot::Client.new { |config|
            config.channel_secret = '10f88109463f23cdf580ecddc364664c'
            config.channel_token = 'PJ13Or13E0TR+dy4CWR30jvA0dMNEqdRqtoB69YIrE7c8AAS0iqVZKgsxfifW4WJbzQlGZGXFKd7fekupwKWE7MikJ+fmy+sZW/30M/KOZJaP83FNSKwWSS1qforSoOhzs5cb2yKG+t1x6MduBJzLwdB04t89/1O/w1cDnyilFU='
        }
    end

    def eat
        render plain: "吃吃吃"
    end

    def request_headers
        render plain: request.headers.to_h.reject{
            |key, value| key.include? '.'
        }
        .map{
            |key, value| "#{key}: #{value}"
        }.sort.join("\n")
    end

    def request_body
        render plain: request.body
    end

    def response_headers
        render plain: response.headers.to_h.map{
            |key, value| "#{key}: #{value}"
    }.sort.join("\n")
    end
    
    def show_response_body
        puts "小秘書在這為您服務"
        render plain: response.body
    end

    def sent_request
        uri = URI('http://localhost:3000/secretary/response_body')
        response = Net::HTTP.get(uri)
        render plain: response
    end

    
end
