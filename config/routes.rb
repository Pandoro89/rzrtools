Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'users#me'

  mount SecuredResqueServer, :at => "/rstatus"

  resources :sessions, :only => [:new,:create] do
    collection do
      match 'destroy', :via => [:get, :delete], :as => :destroy
    end
  end
  resources :users do
    get :me, :on => :collection
    get :profile, :on => :collection
    patch :update, :on => :collection
  end
  resources :fleets, param: :token do
    get    ':token/manage' => 'fleets#manage', :on => :collection, :as => 'manage'
    get    ':token/detail' => 'fleets#detail', :on => :collection, :as => 'detail'
    # post   ':token' => 'fleets#update'
    # patch  ':token' => 'fleets#update'
    # put    ':token' => 'fleets#update'
    get :autocomplete_character_char_name, :on => :collection
    match ':token/special_role' => 'fleets#special_role', :via => [:get, :post], :on => :collection, :as => :special_role
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
    resources :operations
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
