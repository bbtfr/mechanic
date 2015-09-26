# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server 'example.com', user: 'deploy', roles: %w{app db web}, my_property: :my_value
# server 'example.com', user: 'deploy', roles: %w{app web}, other_property: :other_value
# server 'db.example.com', user: 'deploy', roles: %w{db}

server '182.254.151.21', user: 'ubuntu', roles: %w{web app db}
set :rails_env, :production

set :nginx_server_name, 'qichetang.cn www.qichetang.cn es.qichetang.cn'
