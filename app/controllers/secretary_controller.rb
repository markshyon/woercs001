require 'line/bot'
class SecretaryController < ApplicationController
    protect_from_forgery with: :null_session

    def webhook
        # 設定回覆訊息
        reply_text = keyword_reply(received_text)

        # 傳送訊息到Line
        response = reply_to_line(reply_text)
    
        # 回應 200
        head :ok
    end

    # 取得對方說的話
    def received_text
        message = params['events'][0]['message']['text']
        message['text'] unless message.nil?
    end

    # 關鍵字回覆
    def keyword_reply(received_text)
        # 學習紀錄表
        keyword_mapping = {
            'QQ' => '123',
            'ABC' => '456'
        }

        # 查表
        keyword_mapping[received_text]
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
        render plain: "吃土啦"
    end 
    
    def request_headers
        render plain: request.headers.to_h.reject{ |key, value|
          key.include? '.'
        }.map{ |key, value|
          "#{key}: #{value}"
        }.sort.join("\n")
    end
    
    def response_headers
        response.headers['5566'] = 'QQ'
        render plain: response.headers.to_h.map{ |key, value|
          "#{key}: #{value}"
        }.sort.join("\n")
    end
    
    def request_body
        render plain: request.body
    end
    
    def show_response_body
        puts "===這是設定前的response.body:#{response.body}==="
        render plain: "虎哇花哈哈哈"
        puts "===這是設定後的response.body:#{response.body}==="
    end
    
    def sent_request
        uri = URI('http://localhost:3000/kamigo/eat')
        http = Net::HTTP.new(uri.host, uri.port)
        http_request = Net::HTTP::Get.new(uri)
        http_response = http.request(http_request)
    
        render plain: JSON.pretty_generate({
          request_class: request.class,
          response_class: response.class,
          http_request_class: http_request.class,
          http_response_class: http_response.class
        })
    end
    
    def translate_to_korean(message)
        "#{message}油~"
    end
    
end
