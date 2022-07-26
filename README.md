# otus-graduation-project
Выпускной проект OTUS-DevOps-2022

# ИНТРО

Проект представляет собой готовое микросервисное приложение на базе приложения Search Engine Crawler.
Search Engine Crawler - это поисковый бот для сбора текстовой информации с веб-страниц и ссылок.
Для приложения и среды разработки под него полностью поднимается необходимая инфраструктура с помощью Ansible и Terraform:
 - Gitlab-VM (Gitlab-CI c Gitlab-runner)
 - Monitoring-VM (Prometheus и Grafana для мониторинга всей инфраструктуры)
 - App-VM (Docker окружение для приложения)

# Системные требования

Для успешного запуска проекта, в вашем рабочем окружении должны быть установлены:

- python 3.9.5
- ansible 2.12.4
- terraform 1.1.7
- Jinja 3.1.2

Для корректной работы terraform укажите источник, из которого будет устанавливаться провайдер в файле ``` ~/.terraformrc ```
Добавьте в него следующий блок:

 ```
 provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```
  

# Предварительные настройки

 Для запуска проекта необходимо:
  1. Cоздать и подготовить облако в Yandex.Cloud
  
     - [Начало работы с YC](https://cloud.yandex.ru/docs/overview/quickstart)
     
     - [Создание сервисного аккаунта](https://cloud.yandex.ru/docs/iam/operations/sa/create)

     - [Создание авторизованных ключей в YC](https://cloud.yandex.ru/docs/iam/operations/authorized-key/create)
     
     - [Назаначение ролей сервисному аккаунту в YC](https://cloud.yandex.ru/docs/iam/operations/sa/assign-role-for-sa)
     
     Добавьте сервисному аккаунту следующие роли:
     - compute.admin
     - vpc.admin
     - storage.admin
     
     Экспортируйте ключ сервисного аккуунта в файл  ``` ~/yandex-cloud/terraform-key.json ```
     
     Создайте S3 Bucket и настройте Terraform backend
       - [Создание бакета в YC](https://cloud.yandex.ru/docs/storage/operations/buckets/create)
       - [Создание статических ключей доступа YC](https://cloud.yandex.ru/docs/iam/operations/sa/create-access-key)

  2. Сгенерируйте пару SSH ключей для проекта
   `````
   ssh-keygen -C otus-project -f ~/.ssh/otus-project
   `````
   Публичный ключ otus-project.pub поместите в директорию /secret
   
   Не забудьте сделать коммит
   ````
   git add secret/otus_project.pub && git commit -m "update pub key"
   ````
  
  (Путь к публичному ключу задать в файлах terraform.tfvars - public_key_path )
  
  3. Задайте переменные для Terraform в infra/terraform/terraform.tvars
  
| Variable      | Description   | Example             |
| ------------- |:------------- | -------------------:|
| cloud_id      |id облака      |b1gd49j0hgugak1q88cn |
| folder_id     |id каталога    |b1gd49j0hgugak1q89n  |
| subnet_id     |id подсети     |b1gd49j0hgugak1q88cn |
| zone          |Зона           | ru-central1-a       |

  4. Задайте свои переменные для S3 и Gitlab в файлах переменных окружения ansible
    - infra/ansible/environments/prod/group_vars/all.yml
    - microservices/ansible/environments/prod/group_vars/all.yml
 
 | Variable             | Description           | Example                                 |
 | -------------------- |:--------------------- |:-------------------------------------   |
 | tf_bucket_name       |Имя S3 бакета          |terraform-otus-crawler-state             |
 | tf_bucket_access_key |S3 бакет access key    |YCAWEylpPtxRqcXTWSS57Ssw2                |
 | tf_bucket_secret_key |S3 бакет secret key    |YCPKfyd59i0wg85HDE86s8tr7s+pwL9GPXVBYeF5 |
 | gitlab_root_password |Gitlab root пароль     |!Qwerty1                                 |
 | gitlab_runner_token  |токен для ранера       |Dfhju39dbklbnci55jju                     |
 

# Запуск проекта. Создание инфраструктуры.
```
    chmod +x create_infra.sh
    ./create_infra.sh
```

    Cкрипт запускает ansible на установку зависимостей и на отработку playbook.
    Будет создана инфраструктура разработки, включающая в себя:
     - Gitlab-CI
     - 1 активированный Gitlab-runner
     - Monitoring host (Prometheus, Grafana). Настроен сбор метрик с node_exporter со обоих инстансов.
     

# Перенос проекта в Gitlab-CI

Копируем проект в Gitlab-CI либо с GitHub напрямую, указав URL https://github.com/ravaevay/otus-graduation-project.git, либо командой :
``` 
git push <YOUR_GITLAB_CI_URL>/root/$(git rev-parse --show-toplevel | xargs basename).git
```

# Настройка CI/CD

Для успешного тестирования и деплоя задайте следующие переменные для проекта (Admin Area -> Settings -> CI/CD -> Variables). У всех переменных оставьте тип - Variable.

   | Variable             | Value                                             | 
   | :-------------       |:-------------                                     |
   | terraform_key        |содержимое файла ~/yandex-cloud/terraform-key.json |
   | otus_project         |приватный ключ ~/.ssh/otus-project                 |
   | tf_bucket_access_key |S3 access key                                      |
   | tf_bucket_secret_key |S3 secret key                                      |

После пуша проекта в Gitlab-CI автоматически запускается pipeline, который:
 - прогоняет тесты для ui и crawler
 - после успешного тестирования, запускается деплой в prod. (Поднимается докер контейнер, который запускает ansible playbook, который создает с помощью Terraform инстанс app в YC и поднимает на нем приложение docker-compose файлом)
 
 Приложение доступно по адресу:
 ```
 Crawler UI - http://<app_vm_ip>
 Prometheus - http://<monitoring_vm_ip>:9090
 Grafana - http://<monitoring_vm_ip>
 ```
# Удаление проекта

 ```
  chmod +x destroy_infra.sh
  ./destroy_infra.sh
 ```