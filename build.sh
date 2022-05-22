set -e
docker-compose run --service-ports site jekyll build --future

