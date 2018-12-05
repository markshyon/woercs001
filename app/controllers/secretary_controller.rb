require 'line/bot'
class SecretaryController < ApplicationController
    protect_from_forgery with: :null_session

    def webhook

        # 學說話
        reply_text = learn(received_text)

        # 設定回覆訊息
        reply_text = keyword_reply(received_text) if reply_text.nil?

        # 傳送訊息到Line
        response = reply_to_line(reply_text)
    
        # 回應 200
        head :ok
    end

    # 取得對方說的話
    def received_text
        message = params['events'][0]['message']
        message['text'] unless message.nil?
    end

    # 學說話區塊
    def learn(received_text)
        # 如果開頭不是 老賈學說話; 就跳出
        return nil unless received_text[0..5] == '老賈學說話;'

        received_text = received_text[6..-1]
        semicolon_index = received_text.index(';')

        # 找不到分號就跳出
        return nil if semicolon_index.nil?

        keyword = received_text[0..semicolon_index-1]
        message = received_text[semicolon_index+1..-1]

        KeywordMapping.create(keyword: keyword, message: message)
        '報告~是!'
    end

    # 關鍵字回覆
    def keyword_reply(received_text)
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
