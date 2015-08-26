Rails.application.routes.draw do
  mount WeixinRailsMiddleware::Engine, at: "/"
  resource :user do
    get :settings
  end
  resource :user_session, path: "session" do
    post :verification_code
    get :delete
  end
  resource :user_group
  resources :mechanics

  resources :orders do
    resources :bids
    get :review, on: :member
  end

  root to: "users#show"
end
