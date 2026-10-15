# server-based syntax
# 接続先と鍵はリポジトリに書かず、環境変数（ローカルの .env でも可）で渡す
server ENV.fetch("DEPLOY_HOST"), user: ENV.fetch("DEPLOY_USER", "ec2-user"), roles: %w{app db web}

# Global options
set :ssh_options, keys: [File.expand_path(ENV.fetch("DEPLOY_SSH_KEY_PATH"))]
