Rails.application.routes.draw do

  options = Rails.env.production? ? { path: "", constraints: { subdomain: 'es' }} : {}

  namespace :merchants, options do
    resource :merchant_session, path: "session"
    resource :merchant do
      get :forget_password
      match :verification_code, via: [:get, :post, :patch]
      match :confirm, via: [:post, :patch]

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
        get :pend
        get :cancel

        get :refund
        match :notify, via: [:get, :post]
        get :result

        get :confirm
        get :rework

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
      resources :merchants do
        member do
          post :active
          post :inactive
        end
      end
      resources :orders

    end

    root to: "orders#new"
  end

  mount WeixinRailsMiddleware::Engine, at: "/"
  resource :user
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
    concern :confirm do
      collection do
        get :confirmed
      end
      member do
        post :confirm
      end
    end
    resources :users do
      member do
        post :mechanicize
      end
    end
    resources :user_groups, concerns: [:confirm]
    resources :mechanics do
      member do
        post :clientize
      end
    end
    resources :merchants, concerns: [:confirm] do
      member do
        post :active
        post :inactive
      end
    end
    resources :orders
    resources :refunds do
      member do
        post :confirm
      end
    end
    resources :withdrawals, concerns: [:confirm] do
      collection do
        get :settings
        post :settings, action: :update_settings
      end
    end
    namespace :settings do
      resources :skills
      resources :brands
      resources :series, except: :show
    end

    root to: "users#index"
  end

  root to: "users#show"
end
