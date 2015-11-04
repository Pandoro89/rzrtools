# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server 'example.com', user: 'deploy', roles: %w{app db web}, my_property: :my_value
# server 'example.com', user: 'deploy', roles: %w{app web}, other_property: :other_value
# server 'db.example.com', user: 'deploy', roles: %w{db}



# role-based syntax
# ==================

# Defines a role with one or multiple servers. The primary server in each
# group is considered to be the first unless any  hosts have the primary
# property set. Specify the username and a domain or IP for the server.
# Don't use `:all`, it's a meta role.

#role :app, %w{rzrtools@46.101.77.93} #, my_property: :my_value
#role :web, %w{rzrtools@46.101.77.93}#, other_property: :other_value
#role :db,  %w{rzrtools@46.101.77.93}
role :resque_worker, "46.101.77.93"
role :resque_scheduler, "46.101.77.93"
set :resque_log_file, "log/resque.log"
#role :resque_scheduler, "46.101.77.93"
server '46.101.77.93', user: 'rzrtools', roles: %w{web app db}
set :nginx_server_name, 'app.eve-razor.com'
set :nginx_use_ssl, false
#set :nginx_ssl_cert, '/home/rzrtools/ebfbc329-ffbb-47aa-9c4e-34f47724e09f.public.pem'
#set :nginx_ssl_cert_key, '/home/rzrtools/ebfbc329-ffbb-47aa-9c4e-34f47724e09f.private.pem'


# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customise your setup.



# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# The server-based syntax can be used to override options:
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
