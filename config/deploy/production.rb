# server-based syntax
# ======================
server "18.177.55.146", user: "app", roles: %w{app db web}

# Global options
# --------------
set :ssh_options, keys: '/Users/fumta/.ssh/id_rsa'
