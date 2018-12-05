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
        head :ok
    end
end
