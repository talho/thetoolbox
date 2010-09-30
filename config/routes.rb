ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.resource :account, :controller => "users", :action => "index"
  map.resource :admin, :controller => "users", :action => "index"
  map.resources :white_lists
  map.resources :distribution_group, :controller => "distribution_group", :action => "index"

  map.white_list_create "white_lists/:id/create", :controller => "white_lists", :action => "create"

  map.forgot_password "/forgot_password", :controller => "dashboard", :action => "forgot_password"
  map.reset_password "/reset_password/:id", :controller => "users", :action => "reset_password"
  map.create_distribution_group "/create_distribution_group/:id", :controller => "distribution_group", :action => "create_distribution_group"
  map.toggle_user "/users/:id/toggle", :controller => "users", :action => "toggle"

  map.cacti_graphs "/cacti_graphs", :controller => "dashboard", :action => "cacti_graphs"
  map.cacti_graphs_login "/cacti_graphs_login", :controller => "dashboard", :action => "cacti_graphs_login"
  map.cacti "/users/cacti_save", :controller =>"users", :action => "cacti_save"
  map.cacti_log_in "/users/cacti_log_in", :controller => "users", :action => "cacti_log_in"
  map.cacti_log_out "/users/cacti_log_out", :controller => "users", :action => "cacti_log_out"
  map.add_to_distribution "/add_to_distribution_group/", :controller => "distribution_group", :action => "add"
  map.distribution_group_users "/distribution_group_users/", :controller => "distribution_group", :action => "users"
  map.distribution_group_users_remove "/distribution_group_users_remove/", :controller => "distribution_group", :action => "remove_user"
  map.distribution_group_delete "/distribution_group_delete", :controller => "distribution_group", :action => "delete"
  map.reset_password_form "/reset_password_form/:id", :controller => "users", :action => "reset_password_form"
 
  map.exch_users "/exch_users/:id", :controller => "users", :action => "index"
  map.vpn_users "/vpn_users/:id", :controller => "users", :action => "index"
  map.dashboard "/dashboard", :controller => "dashboard", :action => "index"


  map.resources :users, :controller => "users", :member => {:create_white_list_entry => [:put], :create => [:put]}

  map.resource :user_session
  map.root :controller => "user_sessions", :action => "new" # optional, this just sets the root route
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'


end
