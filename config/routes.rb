Rails.application.routes.draw do

  options = Rails.env.production? ? { path: "", constraints: { subdomain: 'es' }} : {}

  namespace :merchants, options do
    resource :merchant_session, path: "session"
    resource :merchant do
      get :forget_password
      match :verification_code, via: [:get, :post, :patch]
      match :confirm, via: [:post, :patch]

      get :password
      patch :password, action: :update_password
    end

    resource :note

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
        post :pend
        post :cancel

        match :refund, via: [:get, :patch]
        match :notify, via: [:get, :post]
        get :result

        post :confirm
        post :rework
        get :revoke

        get :review
        patch :review, action: :update_review

        get :remark
        patch :remark, action: :update_remark
      end
    end

    namespace :hosting do
      resources :orders do
        member do
          get :pick
          patch :pick, action: :update_pick

          post :confirm
          post :rework

          get :review
          patch :review, action: :update_review
        end
      end
    end

    resources :merchants
    resources :mechanics do
      member do
        post :follow
        post :unfollow
        get :remark
        patch :remark, action: :update_remark
        get :reviews
        get :"skills/:skill", action: :skill, as: :skill
      end
    end

    namespace :admin do
      resources :merchants do
        member do
          post :active
          post :inactive
        end
      end
      resources :orders do
        member do
          post :close
        end
      end
      resource :store

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
      patch :review, action: :update_review
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
    concern :cancel do
      collection do
        get :canceled
      end
      member do
        post :cancel
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
        get :settings
        post :settings, action: :update_settings
      end
    end
    resources :orders
    resources :refunds, concerns: [:confirm]
    resources :withdrawals, concerns: [:confirm, :cancel] do
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
