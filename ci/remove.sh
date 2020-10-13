docker-compose --project-directory ./../7/apache/ -f ./../7/apache/compose.yml up -d
docker-compose --project-directory ./../7/apache/ -f ./../7/apache/compose.yml stop
docker-compose --project-directory ./../7/apache/ -f ./../7/apache/compose.yml rm
docker volume rm apache_vdb apache_vsite
docker system prune
rm -rf ../app/drupal/7/*