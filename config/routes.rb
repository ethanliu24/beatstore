Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "pages#home"
  get "admin", to: "admin/tracks#index", as: "admin"

  devise_for :users, path: "", controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    confirmations: "users/confirmations",
    passwords: "users/passwords",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  namespace :users do
    resource :profile, only: [ :edit, :update ]
    resources :hearts, only: [ :index ]
  end

  resources :tracks, only: [ :index, :show ] do
    resource :heart, only: [ :create, :destroy ], module: :tracks
    resource :play, only: [ :create ], module: :tracks, as: "increment_plays"
  end

  resources :comments, only: [ :create, :update, :destroy ] do
    member do
      post "like", to: "comments/interactions#like"
      delete "like", to: "comments/interactions#unlike"
      post "dislike", to: "comments/interactions#dislike"
      delete "dislike", to: "comments/interactions#undislike"
    end
  end

  resources :cart_items, only: [ :create, :destroy ]

  namespace :admin do
    resources :tracks, except: [ :show ]
    resources :licenses, except: [ :show ] do
      member do
        post :apply_to_all
        delete :remove_from_all
      end
    end
  end

  namespace :api do
    resources :tracks, only: [ :show ]
    namespace :templates do
      get :contracts, to: "get_contract_templates"
    end
  end

  scope :download, controller: :downloads do
    scope "track/:id" do
      get "free", to: "free_download", as: "download_track_free"
    end
  end

  scope :location, controller: :locations do
    get "provinces", action: "provinces", as: "location_provinces"
  end

  scope :modal, controller: :modals do
    get :auth_prompt, action: "auth_prompt", as: "auth_prompt_modal"
    get :track_image_upload, action: "track_image_upload", as: "track_image_upload_modal"
    get :user_pfp_upload, action: "user_pfp_upload", as: "user_pfp_upload_modal"
    get :delete_account, action: "delete_account", as: "delete_account_modal"
    get :preview_contract, action: "preview_contract", as: "preview_contract_modal"
    get "delete_comment/:id", action: "delete_comment", as: "delete_comment_modal"
    get "track_more_info/:id", action: "track_more_info", as: "track_more_info_modal"
    get "track_purchase/:id", action: "track_purchase", as: "track_purchase_modal"
  end
end
