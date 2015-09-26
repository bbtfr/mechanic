Rails.application.routes.draw do

  options = Rails.env.production? ? { path: "", constraints: { subdomain: 'es' }} : {}

  namespace :merchants, options do
    resource :merchant_session, path: "session"
    resource :merchant do
      get :forget_password
      post :verification_code
      patch :verification_code
      patch :confirm

      get :change_password
      patch :password
    end

    resources :orders do
      resources :bids do
        member do
          get :pick
        end
      end

      collection do
        get :"pay/:id", action: :pay, as: :pay
      end

      member do
        get :cancel

        get :refund
        post :notify
        get :result

        get :confirm

        get :review
      end
    end

    resources :merchants
    resources :mechanics do
      member do
        post :follow
        post :unfollow
        get :reviews
      end
    end

    namespace :admin do
      resources :merchants
      resources :orders

    end

    root to: "orders#new"
  end

  mount WeixinRailsMiddleware::Engine, at: "/"
  resource :user do
    get :settings
  end
  resource :user_session, path: "session" do
    post :verification_code
  end
  resource :user_group do
    get :weixin_qr_code
    get :users
  end
  resources :mechanics do
    member do
      get :follow
      get :unfollow
      get :reviews
    end
  end

  resources :orders do
    resources :bids do
      member do
        get :pick
      end
    end

    collection do
      get :"pay/:id", action: :pay, as: :pay
    end

    member do
      get :cancel

      get :refund
      post :notify
      get :result

      get :work
      patch :finish
      get :confirm

      get :review
    end
  end

  resources :withdrawals

  namespace :admin do
    resources :users
    resources :user_groups do
      collection do
        get :confirmed
      end
      member do
        post :confirm
      end
    end
    resources :mechanics
    resources :orders
    resources :withdrawals do
      member do
        post :confirm
      end
    end
    namespace :setting do
      resources :brands
      resources :series, except: :show
    end

    root to: "users#index"
  end

  root to: "users#show"
end
