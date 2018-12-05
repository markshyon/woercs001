Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'secretary/eat', to: 'secretary#eat'
  get 'secretary/request_headers', to: 'secretary#request_headers'
  get 'secretary/request_body', to: 'secretary#request_body'
  get 'secretary/response_headers', to: 'secretary#response_headers'
  get 'secretary/response_body', to: 'secretary#show_response_body'
  get 'secretary/sent_request', to: 'secretary#sent_request'
  post 'secretary/webhook', to: 'secretary#webhook'
end
