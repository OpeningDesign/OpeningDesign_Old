Odr::Application.routes.draw do

  get "open_aec/home"

  resources :collaboration_requests
  resource :twitter_registration
  resource :linkedin_registration

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  resources :nodes do
    member do
      post 'upload'
    end
    post 'subscribe'
    post 'unsubscribe'
    post 'move'
    post 'cancelmove'
    post 'submitmove'
    resources :folders
    resources :projects
    resources :sketchspaces
    resources :tags
    resources :votes
    post 'delete_tag'
    resources :collaborators
  end
  resources :documents do
    member do
      get 'download'
    end
  end
  resources :document_versions do
    member do
      get 'download'
    end
  end
  resources :projects do
    get 'download'
  end
  resources :folders
  match '/sketchspaces/cloned' => 'sketchspaces#cloned'
  get '/sketchspaces/submitted' => 'sketchspaces#submitted'
  get '/sketchspaces/authorized' => 'sketchspaces#authorized'
  resources :sketchspaces

  post "let_me_know/create"
  get "profile/show"
  get "profile/display_name"
  get "subscription/show"
  post "subscription/upgrade"
  post "subscription/cancel"

  resources :tags do
    post 'subscribe'
    post 'unsubscribe'
  end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" },
    :path_prefix => 'd'
  devise_scope :user do
    get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
  end

  resources :users do
    post 'subscribe'
    post 'unsubscribe'
  end

  resource :landing
  get '/unsupported' => 'landing#unsupported'

  root :to => 'landing#index'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
