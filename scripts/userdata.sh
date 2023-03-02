#!/bin/bash
sudo yum update -y
sudo timedatectl set-timezone Asia/Tokyo
sudo localectl set-locale LANG=ja_JP.utf8
sudo source /etc/locale.conf
sudo amazon-linux-extras install -y nginx1 postgresql12
sudo yum install -y gcc-c++ make patch git openssl-devel sudo readline-devel zlib-devel ImageMagick-devel curl libffi-devel libicu-devel libxml2-devel libxslt-devel postgresql-server postgresql-devel poppler-utils poppler-data
sudo systemctl restart crond.service
sudo systemctl start nginx
sudo systemctl enable nginx
sudo /usr/bin/postgresql-setup --initdb --unit postgresql
sudo systemctl start postgresql
sudo systemctl enable postgresql
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
touch /var/www/issues_app/shared/.env
gem install bundler
