#!/bin/bash

set -eu

URL=local.chalashop.vn

cp .env.dev .env

# Firing up Docker containers
echo "===> Starting up Docker containers..."
docker-compose stop
docker-compose up -d
echo "===> Docker containers started"

echo "===> Start installing composer..."
docker-compose exec -T app composer install
docker-compose exec -T app cp .env.example .env
docker-compose exec -T app php artisan key:generate
docker-compose exec -T app composer dump-autoload

echo "===> Running artisan commands"
docker-compose exec app bash -c "cd /var/www && php artisan migrate:fresh --env=local"
docker-compose exec app bash -c "cd /var/www && php artisan db:seed --env=local"
docker-compose exec app bash -c "cd /var/www && php artisan config:clear --env=local"
echo "===> Completed: Set app key, migrate database and seeding database"


echo "===> Restart Docker containers..."
docker-compose restart

# Setting Hosts
echo "===> Add domain to hosts file"
sudo -- sh -c "echo '127.0.0.1 ${URL}' >> /etc/hosts"

# Open Site in browser
open https://"${URL}"
echo "===> Local setup successfully finished!"
