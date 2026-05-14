Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :logistic_user do
        get '/suppliers', to: 'suppliers#index'
        get '/suppliers/select', to: 'suppliers#index_select'
        get '/suppliers/:id', to: 'suppliers#show'
      end
    end
  end
end