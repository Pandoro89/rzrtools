require "resque_web"
ResqueWeb::Engine.eager_load! # hack

Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'users#me'

  mount LetsencryptPlugin::Engine, at: '/'  # It must be at root level

  resque_web_constraint = lambda do |request|
    cu = User.find_by_id(request.session[:user_id])
    cu.present? && cu.respond_to?(:admin?) && cu.admin?
  end

  constraints resque_web_constraint do
    # mount ResqueWeb::Engine => '/admin/resque_web', as: 'resque_web'
    mount Resque::Server.new, :at => "/admin/resque_web", as: 'resque_web'
  end

  resources :sessions, :only => [:new,:create] do
    collection do
      match 'destroy', :via => [:get, :delete], :as => :destroy
    end
  end

  resources :signatures
  resources :scans, param: :token

  resources :api_keys

  resources :users do
    get :me, :on => :collection
    get :profile, :on => :collection
    patch :update, :on => :collection
  end
  get 'profile' =>  'users#profile', :as => 'profile'

  resources :fleets, param: :token do
    get    'rewards'       => 'fleets#rewards',     :on => :collection, :as => 'rewards'
    get    'fc_rewards'    => 'fleets#fc_rewards',  :on => :collection, :as => 'fc_rewards'
    get    'ping_helper'   => 'fleets#ping_helper', :on => :collection, :as => 'ping_helper'
    get    ':token/manage' => 'fleets#manage',      :on => :collection, :as => 'manage'
    get    ':token/detail' => 'fleets#detail',      :on => :collection, :as => 'detail'
    get    ':token/detail' => 'fleets#close',       :on => :collection, :as => 'close'
    # post   ':token' => 'fleets#update'
    # patch  ':token' => 'fleets#update'
    # put    ':token' => 'fleets#update'
    get :autocomplete_character_char_name, :on => :collection
    get :autocomplete_inv_type_name, :on => :collection
    get :autocomplete_group_name, :on => :collection
    match ':token/special_role' => 'fleets#special_role', :via => [:get, :post], :on => :collection, :as => :special_role
    match ':token/remove_role' => 'fleets#remove_role', :via => [:delete], :on => :collection, :as => :remove_role
  end
  resources :watchlists do 
    get :autocomplete_alliance_cache_name, :on => :collection
    get :alliance, :on => :collection
  end

  resources :travel, :only => [:index] do
    get :autocomplete_solar_system_name, :on => :collection
    post :route,:on => :collection
  end

  get 'pap/:token' =>  'fleets#join', :as => 'pap'

  namespace :admin do
    # Directs /admin/products/* to Admin::ProductsController
    # (app/controllers/admin/products_controller.rb)
    resources :users do
      post ':id/role_add' => 'users#role_add', :on => :collection, :as => 'role_add'
      post ':id/role_delete' => 'users#role_delete', :on => :collection, :as => 'role_delete'
    end
    resources :operations, :only => [] do
      match 'manual_alts' => 'operations#manual_alts', :via => [:get, :post], :on => :collection, :as => :manual_alts
      match 'manual_jump_bridges' => 'operations#manual_jump_bridges', :via => [:get, :post], :on => :collection, :as => :manual_jump_bridges
    end
    resources :jump_bridges
    resources :watchlists
    resources :fleet_position_rules
  end

  #api
  namespace :api do
    namespace :v1 do
      resources :characters, only: [:index, :create, :show, :update, :destroy]
      resources :rash_members, only: [:index, :show, :report] do
        post 'report' => 'rash_members#report', :on => :collection
      end
      resources :cron, only: [] do
        post 'run' => 'cron#run', :on => :collection
      end
    end
  end

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
