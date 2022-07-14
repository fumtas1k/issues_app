# server-based syntax
server ENV['HTTP_HOST'], user: "app", roles: %w{app db web}

# Global options
set :ssh_options, keys: '/Users/fumta/.ssh/id_rsa'
