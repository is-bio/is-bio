Rails.application.routes.draw do
  namespace :api do
    defaults({ format: :json }) do
      namespace :v1 do
        post "github-events" => "github_events#handle"
      end
    end
  end

  resource :session
  resources :passwords, param: :token

  namespace :admin do
    root to: "main#root"

    resources :posts, only: %i[new create edit update]

    resources :categories, only: :index

    resources :social_media_accounts, only: [ :index, :edit, :update ]

    resources :settings, only: [ :index, :edit, :update ]

    resources :github_app_settings, only: [ :index, :edit, :update ]
  end

  resources :posts, only: [ :index ]
  root "posts#index"
  get "about" => "posts#about", as: :about

  resources :categories, only: :index
  get "category" => "categories#index"
  get "category/:name" => "categories#show"
  get "drafts" => "categories#drafts_index", as: :drafts
  get "drafts/:name" => "categories#drafts_show"

  # Subscription routes
  post "subscriptions" => "subscriptions#create", as: :subscriptions
  get "subscriptions/confirm/:token" => "subscriptions#confirm", as: :confirm_subscription

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # This line needs to be placed at the end
  get ":permalink-:id" => "posts#show"
end
