# Docker Laravel-app skeleton

Рабочий, пустой Laravel в Docker-контейнерах, с базой данных, томами и PhpMyAdmin

Основано на [How To Set Up Laravel, Nginx, and MySQL with Docker Compose](https://www.digitalocean.com/community/tutorials/how-to-set-up-laravel-nginx-and-mysql-with-docker-compose)

После запуска контейнера приложение доступно на [localhost](http://localhost/)  
PhpMyAdmin доступен на [localhost:8080](localhost:8080).  

## Intro

Замысел в следующем:  
В скелет [Laravel](https://github.com/laravel/laravel.git)-приложения интегрируется Docker-конфигурация, т.е. Laravel-приложение будет запускаться в контейнере и никому не будет мешать.  

Создать каталог проекта, например, `project` и расположиться в нем.  

## Step 1 — Downloading Laravel and Installing Dependencies

Клонировать [Laravel](https://github.com/laravel/laravel.git)-приложение:

Копировать/вставить в консоль весь следующий абзац команд, с пустой строкой включительно и нажать Enter:

```sh
git clone https://github.com/laravel/laravel.git laravel-app && \
rm -rf ./laravel-app/.git && \
rm -rf ./laravel-app/.github && \
mv ./laravel-app/README.md ./laravel-app/README_laravel.md

```

```sh
cd ./laravel-app
docker run --rm -v $(pwd):/app composer install

cd ..
```

Выхлоп команды:

<pre>
81 packages you are using are looking for funding.
Use the `composer fund` command to find out more!
> @php artisan vendor:publish --tag=laravel-assets --ansi --force

   INFO  No publishable resources for tag [laravel-assets].  
</pre>

В сеансе обычного пользователя выполнить:

```sh
sudo chown -R $USER:$USER ./laravel-app

```

## Step 1.1 - Добавление конфигурационных файлов Docker'а

Оставаясь в том же каталоге `project`, клонировать репозиторий [docker_laravel-app_skeleton](https://github.com/itechnocrat/docker_laravel-app_skeleton):  

Копировать/вставить в консоль весь следующий абзац команд, с пустой строкой включительно и нажать Enter:

```sh
git clone https://github.com/itechnocrat/docker_laravel-app_skeleton && \
rm -rf ./docker_laravel-app_skeleton/.git

```

Скопировать содержимое второго репозитория в первый и удалить второй, он больше не нужен:  

Копировать/вставить в консоль весь следующий абзац команд, с пустой строкой включительно и нажать Enter:

```sh
cp -r ./docker_laravel-app_skeleton/* ./laravel-app/ && \
cp -r ./docker_laravel-app_skeleton/.env ./laravel-app/ && \
rm -rf ./docker_laravel-app_skeleton

```

Отсюда возможно сразу перейти к шагу 8.1

вырезано

## Step 8.1 - Start laravel_app

```sh
cd ./laravel-app
docker-compose up -d
docker ps # просто посмотреть выполняемые контейнеры
# скопировать следующие 3 строки, вместе с пустой и нажать Enter
docker-compose exec app php artisan key:generate && \
docker-compose exec app php artisan config:cache

```

Контейнер и Laravel-приложение готовы и работают.  

Web-server и модуль php обрабатывают каталог `public`, остальные каталоги обеспечивают работу этого каталога.

Теперь надо подготовить базу данных:

## Step 9 — Creating a User for MySQL

```sh
docker-compose exec db bash
mysql -u root -pr00t
# пароль r00t
```

Для MySQL 8:  
Сначала явно создать юзера командой:

```sql
CREATE USER 'laraveluser'@'%' IDENTIFIED BY 'laraveluser_password';
```

Затем давать ему права:

```sql
GRANT ALL ON laravel.* TO 'laraveluser'@'%';
```

```sh
exit
```

До 8-ой версии

```sql
show databases;
GRANT ALL ON laravel.* TO 'laraveluser'@'%' IDENTIFIED BY 'laraveluser_password';
FLUSH PRIVILEGES;
EXIT;
```

## 10 - Использование

Теперь возможно переходить по ссылкам:

[localhost](http://localhost/)  
[localhost/phpinfo.php](http://localhost/phpinfo.php)  
[PhpMyAdmin](http://localhost:8080/)

После открытия страницы PMA, смотреть на сообщение внизу.  
Follow the warning’s link to “Create a database” to complete the installation.  
Your user account will need permission to create new databases on the server.

На этом всё.

После изменений в конфиг-файлах перезапускать сборку следующим образом:

```sh
docker-compose up -d --build
```

Для очищения всего, что есть под управлением Docker:

Копировать/вставить в консоль весь следующий абзац команд, с пустой строкой включительно и нажать Enter:

```sh
docker system prune && \
docker system prune -a --volumes && \
docker image prune && \
docker container prune && \
docker volume prune && \
docker network prune

```

Внимание, будет удалено всё: все образы, контейнеры, сети.

## Step 11 — Migrating Data and Working with the Tinker Console

With your application running, you can migrate your data and experiment with the tinker command, which will initiate a PsySH console with Laravel preloaded. PsySH is a runtime developer console and interactive debugger for PHP, and Tinker is a REPL specifically for Laravel. Using the tinker command will allow you to interact with your Laravel application from the command line in an interactive shell.

First, `project` the connection to MySQL by running the Laravel artisan migrate command, which creates a migrations table in the database from inside the container:

```sh
docker-compose exec app php artisan migrate
docker-compose exec app php artisan tinker
```

`>>> \DB::table('migrations')->get();`  
`exit`

## Conclusion

...

## Дополнительные материалы

[How to Run PHPMyAdmin in a Docker Container](https://www.howtogeek.com/devops/how-to-run-phpmyadmin-in-a-docker-container/)  
[Настройка Laravel, Nginx и MySQL с Docker Compose](https://www.digitalocean.com/community/tutorials/how-to-set-up-laravel-nginx-and-mysql-with-docker-compose-ru)  
[Сборка PHP 7.4 docker образа](http://dimonz.ru/post/create-php-7-4-docker-image)
[Wordpress & Docker](https://gist.github.com/bradtraversy/faa8de544c62eef3f31de406982f1d42)  
[MariaDB + Phpmyadmin + Docker: Running Local Database](https://hackernoon.com/mariadb-phpmyadmin-docker-running-local-database-ok9q36ji)  
[Set up a MySQL Server and phpMyAdmin with Docker](https://linuxhint.com/mysql_server_docker/)
[Structuring the Docker setup for PHP Projects](https://www.pascallandau.com/blog/structuring-the-docker-setup-for-php-projects/)  
[Docker for PHP: A Start-to-Finish Guide](https://stackify.com/docker-for-php-a-start-to-finish-guide/)  
[General purpose PHP images for Docker](https://github.com/thecodingmachine/docker-images-php)  
[Using Docker for PHP development](https://www.pixelite.co.nz/article/using-docker-for-local-php-development-2/)  
[Setup a basic Local PHP Development Environment in Docker](https://dev.to/truthseekers/setup-a-basic-local-php-development-environment-in-docker-kod)
