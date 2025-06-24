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

  devise_for :users, path: "", controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    confirmations: "users/confirmations",
    passwords: "users/passwords",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  namespace :users do
    resource :profile, only: [ :edit, :update ]
  end

  resources :tracks, only: [ :index, :show ] do
    resource :heart, only: [ :create, :destroy ]
  end

  namespace :admin do
    resources :tracks, except: [ :show ]
  end

  scope :modal, controller: :modals do
    get :auth_prompt, action: "auth_prompt", as: "auth_prompt_modal"
    get :track_image_upload, action: "track_image_upload", as: "track_image_upload_modal"
  end
end
