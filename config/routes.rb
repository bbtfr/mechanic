Rails.application.routes.draw do
  resource :user do
    get :settings
  end
  resource :user_session, path: "session" do
    post :verification_code
  end
  resource :user_group

  resources :orders do
    resources :bids
    get :review, on: :member
  end

  root to: "users#show"
end
