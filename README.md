# otus-graduation-project
Выпускной проект OTUS-DevOps-2022

Системные требования:

- python 3.9.5
- ansible 2.12.4
- terraform 1.1.7

# ИНТРО

Проект представляет собой готовое микросервисное приложение на базе приложения Search Engine Crawler.
Search Engine Crawler - это поисковый бот для сбора текстовой информации с веб-страниц и ссылок.
Для приложения и среды разработки под него полностью поднимается необходимая инфраструктура с помощью Ansible и Terraform:
 - Gitlab-VM (Gitlab-CI c Gitlab-runner)
 - Monitoring-VM (Prometheus и Grafana для мониторинга всей инфраструктуры)
 - App-VM (Docker окружение для приложения)

# Предварительные настройки

 Для запуска проекта необходимо:
  - сгенерированная пара SSH ключей для проекта (Путь к публичному ключу задать в файлах terraform.tfvars - public_key_path )
  - yandex cloud Service account key (Необходимо создать и экспортировать ключ. Далее задать путь к нему в infra/terrafrorm/main.tf и microservices/terraform/main.tf - service_account_key_file)
  - Задать свои переменные в infra/terraform/terraform.tfvars и microservices/terraform/terraform.tfvars
  - Создать Yandex Cloud Bucket и задать настройки в файле infra/ansible/environments/prod/group_vars/all.yml

# Запуск проекта
```
    chmod +x create_infra.sh
    ./create_infra.sh
```

    Будет создана инфраструктура разработки. 

Далее пушим проект в Gitlab-CI либо с GitHub напрямую, указав URL https://github.com/ravaevay/otus-graduation-project.git, либо командой :
``` 
git push <YOUR_GITLAB_CI_URL>/root/$(git rev-parse --show-toplevel | xargs basename).git
```
Тесты запускаются автоматически для Crawler и UI контейнеров.
