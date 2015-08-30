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
  resources :mechanics do
    member do
      get :follow
      get :unfollow
    end
  end

  resources :orders do
    resources :bids do
      member do
        get :pick
      end
    end

    member do
      get :refund
      get :pay
      get :result

      get :work
      patch :finish
      get :confirm

      get :review
    end
  end

  root to: "users#show"
end
