# server-based syntax
server "13.115.29.135", user: "ec2-user", roles: %w{app db web}

# Global options
set :ssh_options, keys: [File.expand_path('~/.ssh/aws2023.pem')]
