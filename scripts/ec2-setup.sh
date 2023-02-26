#!/bin/bash
sudo mkdir /usr/local/rbenv
sudo chown $USER /usr/local/rbenv
git clone https://github.com/rbenv/rbenv.git /usr/local/rbenv
echo 'export RBENV_ROOT="/usr/local/rbenv"' >> ~/.bashrc
echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init --no-rehash -)"' >> ~/.bashrc
source ~/.bashrc
git clone https://github.com/rbenv/ruby-build.git /usr/local/rbenv/plugins/ruby-build
rbenv install 3.0.1
rbenv global 3.0.1
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
. ~/.nvm/nvm.sh
nvm install v16.16.0
npm install -g npm@9.5.1
npm install --location=global yarn
sudo mkdir /var/www
sudo chown $USER /var/www
mkdir -p /var/www/issues_app/shared
gem install bundler
