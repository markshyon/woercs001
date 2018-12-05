require 'line/bot'
class SecretaryController < ApplicationController
    protect_from_forgery with: :null_session

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

    def webhook
        # Line Bot API 物件初始化
        client = Line::Bot::Client.new { |config|
            config.channel_secret = '10f88109463f23cdf580ecddc364664c'
            config.channel_token = 'PJ13Or13E0TR+dy4CWR30jvA0dMNEqdRqtoB69YIrE7c8AAS0iqVZKgsxfifW4WJbzQlGZGXFKd7fekupwKWE7MikJ+fmy+sZW/30M/KOZJaP83FNSKwWSS1qforSoOhzs5cb2yKG+t1x6MduBJzLwdB04t89/1O/w1cDnyilFU='
        }
  
        # 取得 reply token
        reply_token = params['events'][0]['replyToken']

        # 設定回覆訊息
        message = {
            type: 'text',
            text: '好哦～好哦～'
        }

        # 傳送訊息
        response = client.reply_message(reply_token, message)
    
        # 回應 200
        head :ok
    end
end
