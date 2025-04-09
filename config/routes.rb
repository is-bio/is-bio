# == Route Map
#
#                                         Prefix Verb   URI Pattern                                                                                       Controller#Action
#                                                       /assets                                                                                           Propshaft::Server
#                                           jobs        /jobs                                                                                             MissionControl::Jobs::Engine
#                           api_v1_github_events POST   /api/v1/github-events(.:format)                                                                   api/v1/github_events#handle {:format=>:json}
#                                    new_session GET    /session/new(.:format)                                                                            sessions#new
#                                   edit_session GET    /session/edit(.:format)                                                                           sessions#edit
#                                        session GET    /session(.:format)                                                                                sessions#show
#                                                PATCH  /session(.:format)                                                                                sessions#update
#                                                PUT    /session(.:format)                                                                                sessions#update
#                                                DELETE /session(.:format)                                                                                sessions#destroy
#                                                POST   /session(.:format)                                                                                sessions#create
#                                      passwords GET    /passwords(.:format)                                                                              passwords#index
#                                                POST   /passwords(.:format)                                                                              passwords#create
#                                   new_password GET    /passwords/new(.:format)                                                                          passwords#new
#                                  edit_password GET    /passwords/:token/edit(.:format)                                                                  passwords#edit
#                                       password GET    /passwords/:token(.:format)                                                                       passwords#show
#                                                PATCH  /passwords/:token(.:format)                                                                       passwords#update
#                                                PUT    /passwords/:token(.:format)                                                                       passwords#update
#                                                DELETE /passwords/:token(.:format)                                                                       passwords#destroy
#                                     admin_root GET    /admin(.:format)                                                                                  admin/main#root
#                                    admin_posts POST   /admin/posts(.:format)                                                                            admin/posts#create
#                                 new_admin_post GET    /admin/posts/new(.:format)                                                                        admin/posts#new
#                                edit_admin_post GET    /admin/posts/:id/edit(.:format)                                                                   admin/posts#edit
#                                     admin_post PATCH  /admin/posts/:id(.:format)                                                                        admin/posts#update
#                                                PUT    /admin/posts/:id(.:format)                                                                        admin/posts#update
#                               admin_categories GET    /admin/categories(.:format)                                                                       admin/categories#index
#                    admin_social_media_accounts GET    /admin/social_media_accounts(.:format)                                                            admin/social_media_accounts#index
#                edit_admin_social_media_account GET    /admin/social_media_accounts/:id/edit(.:format)                                                   admin/social_media_accounts#edit
#                     admin_social_media_account PATCH  /admin/social_media_accounts/:id(.:format)                                                        admin/social_media_accounts#update
#                                                PUT    /admin/social_media_accounts/:id(.:format)                                                        admin/social_media_accounts#update
#                                 admin_settings GET    /admin/settings(.:format)                                                                         admin/settings#index
#                             edit_admin_setting GET    /admin/settings/:id/edit(.:format)                                                                admin/settings#edit
#                                  admin_setting PATCH  /admin/settings/:id(.:format)                                                                     admin/settings#update
#                                                PUT    /admin/settings/:id(.:format)                                                                     admin/settings#update
#                      admin_github_app_settings GET    /admin/github_app_settings(.:format)                                                              admin/github_app_settings#index
#                  edit_admin_github_app_setting GET    /admin/github_app_settings/:id/edit(.:format)                                                     admin/github_app_settings#edit
#                       admin_github_app_setting PATCH  /admin/github_app_settings/:id(.:format)                                                          admin/github_app_settings#update
#                                                PUT    /admin/github_app_settings/:id(.:format)                                                          admin/github_app_settings#update
# send_verification_email_admin_email_subscriber POST   /admin/email_subscribers/:id/send_verification_email(.:format)                                    admin/email_subscribers#send_verification_email
#                        admin_email_subscribers GET    /admin/email_subscribers(.:format)                                                                admin/email_subscribers#index
#                                                POST   /admin/email_subscribers(.:format)                                                                admin/email_subscribers#create
#                     new_admin_email_subscriber GET    /admin/email_subscribers/new(.:format)                                                            admin/email_subscribers#new
#                         admin_email_subscriber DELETE /admin/email_subscribers/:id(.:format)                                                            admin/email_subscribers#destroy
#                                          posts GET    /posts(.:format)                                                                                  posts#index
#                                           root GET    /                                                                                                 posts#index
#                                          about GET    /about(.:format)                                                                                  posts#about
#                                           hire GET    /hire(.:format)                                                                                   posts#hire
#                                     categories GET    /categories(.:format)                                                                             categories#index
#                                       category GET    /category(.:format)                                                                               categories#index
#                                                GET    /category/:name(.:format)                                                                         categories#show
#                                         drafts GET    /drafts(.:format)                                                                                 categories#drafts_index
#                                                GET    /drafts/:name(.:format)                                                                           categories#drafts_show
#                                  subscriptions POST   /subscriptions(.:format)                                                                          subscriptions#create
#                           confirm_subscription GET    /subscriptions/confirm/:token(.:format)                                                           subscriptions#confirm
#                             rails_health_check GET    /up(.:format)                                                                                     rails/health#show
#                                                GET    /:permalink-:id(.:format)                                                                         posts#show
#               turbo_recede_historical_location GET    /recede_historical_location(.:format)                                                             turbo/native/navigation#recede
#               turbo_resume_historical_location GET    /resume_historical_location(.:format)                                                             turbo/native/navigation#resume
#              turbo_refresh_historical_location GET    /refresh_historical_location(.:format)                                                            turbo/native/navigation#refresh
#                  rails_postmark_inbound_emails POST   /rails/action_mailbox/postmark/inbound_emails(.:format)                                           action_mailbox/ingresses/postmark/inbound_emails#create
#                     rails_relay_inbound_emails POST   /rails/action_mailbox/relay/inbound_emails(.:format)                                              action_mailbox/ingresses/relay/inbound_emails#create
#                  rails_sendgrid_inbound_emails POST   /rails/action_mailbox/sendgrid/inbound_emails(.:format)                                           action_mailbox/ingresses/sendgrid/inbound_emails#create
#            rails_mandrill_inbound_health_check GET    /rails/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#health_check
#                  rails_mandrill_inbound_emails POST   /rails/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#create
#                   rails_mailgun_inbound_emails POST   /rails/action_mailbox/mailgun/inbound_emails/mime(.:format)                                       action_mailbox/ingresses/mailgun/inbound_emails#create
#                 rails_conductor_inbound_emails GET    /rails/conductor/action_mailbox/inbound_emails(.:format)                                          rails/conductor/action_mailbox/inbound_emails#index
#                                                POST   /rails/conductor/action_mailbox/inbound_emails(.:format)                                          rails/conductor/action_mailbox/inbound_emails#create
#              new_rails_conductor_inbound_email GET    /rails/conductor/action_mailbox/inbound_emails/new(.:format)                                      rails/conductor/action_mailbox/inbound_emails#new
#                  rails_conductor_inbound_email GET    /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                                      rails/conductor/action_mailbox/inbound_emails#show
#       new_rails_conductor_inbound_email_source GET    /rails/conductor/action_mailbox/inbound_emails/sources/new(.:format)                              rails/conductor/action_mailbox/inbound_emails/sources#new
#          rails_conductor_inbound_email_sources POST   /rails/conductor/action_mailbox/inbound_emails/sources(.:format)                                  rails/conductor/action_mailbox/inbound_emails/sources#create
#          rails_conductor_inbound_email_reroute POST   /rails/conductor/action_mailbox/:inbound_email_id/reroute(.:format)                               rails/conductor/action_mailbox/reroutes#create
#       rails_conductor_inbound_email_incinerate POST   /rails/conductor/action_mailbox/:inbound_email_id/incinerate(.:format)                            rails/conductor/action_mailbox/incinerates#create
#                             rails_service_blob GET    /rails/active_storage/blobs/redirect/:signed_id/*filename(.:format)                               active_storage/blobs/redirect#show
#                       rails_service_blob_proxy GET    /rails/active_storage/blobs/proxy/:signed_id/*filename(.:format)                                  active_storage/blobs/proxy#show
#                                                GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                                        active_storage/blobs/redirect#show
#                      rails_blob_representation GET    /rails/active_storage/representations/redirect/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations/redirect#show
#                rails_blob_representation_proxy GET    /rails/active_storage/representations/proxy/:signed_blob_id/:variation_key/*filename(.:format)    active_storage/representations/proxy#show
#                                                GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)          active_storage/representations/redirect#show
#                             rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                                       active_storage/disk#show
#                      update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                               active_storage/disk#update
#                           rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                                    active_storage/direct_uploads#create
#
# Routes for MissionControl::Jobs::Engine:
#     application_queue_pause DELETE /applications/:application_id/queues/:queue_id/pause(.:format) mission_control/jobs/queues/pauses#destroy
#                             POST   /applications/:application_id/queues/:queue_id/pause(.:format) mission_control/jobs/queues/pauses#create
#          application_queues GET    /applications/:application_id/queues(.:format)                 mission_control/jobs/queues#index
#           application_queue GET    /applications/:application_id/queues/:id(.:format)             mission_control/jobs/queues#show
#       application_job_retry POST   /applications/:application_id/jobs/:job_id/retry(.:format)     mission_control/jobs/retries#create
#     application_job_discard POST   /applications/:application_id/jobs/:job_id/discard(.:format)   mission_control/jobs/discards#create
#    application_job_dispatch POST   /applications/:application_id/jobs/:job_id/dispatch(.:format)  mission_control/jobs/dispatches#create
#    application_bulk_retries POST   /applications/:application_id/jobs/bulk_retries(.:format)      mission_control/jobs/bulk_retries#create
#   application_bulk_discards POST   /applications/:application_id/jobs/bulk_discards(.:format)     mission_control/jobs/bulk_discards#create
#             application_job GET    /applications/:application_id/jobs/:id(.:format)               mission_control/jobs/jobs#show
#            application_jobs GET    /applications/:application_id/:status/jobs(.:format)           mission_control/jobs/jobs#index
#         application_workers GET    /applications/:application_id/workers(.:format)                mission_control/jobs/workers#index
#          application_worker GET    /applications/:application_id/workers/:id(.:format)            mission_control/jobs/workers#show
# application_recurring_tasks GET    /applications/:application_id/recurring_tasks(.:format)        mission_control/jobs/recurring_tasks#index
#  application_recurring_task GET    /applications/:application_id/recurring_tasks/:id(.:format)    mission_control/jobs/recurring_tasks#show
#                             PATCH  /applications/:application_id/recurring_tasks/:id(.:format)    mission_control/jobs/recurring_tasks#update
#                             PUT    /applications/:application_id/recurring_tasks/:id(.:format)    mission_control/jobs/recurring_tasks#update
#                      queues GET    /queues(.:format)                                              mission_control/jobs/queues#index
#                       queue GET    /queues/:id(.:format)                                          mission_control/jobs/queues#show
#                         job GET    /jobs/:id(.:format)                                            mission_control/jobs/jobs#show
#                        jobs GET    /:status/jobs(.:format)                                        mission_control/jobs/jobs#index
#                        root GET    /                                                              mission_control/jobs/queues#index

Rails.application.routes.draw do
  mount MissionControl::Jobs::Engine, at: "/jobs", as: :jobs

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
    resources :email_subscribers, only: %i[index new create destroy] do
      member do
        post :send_verification_email
      end
    end
  end

  resources :posts, only: [ :index ]
  root "posts#index"
  get "about" => "posts#about", as: :about
  get "hire" => "posts#hire", as: :hire

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
