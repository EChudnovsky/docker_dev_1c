# СБОРКА ОБРАЗОВ DOCKER
---

При сборке образов используются параметризованные аргументы в которых передаются сведения с путями инсталяционных файлов.
Для упрощения в качестве путей к файлам используется адрес web-сервера, как источник файлов (например: nginx).
С помощью сборочных аргументов, можно повлиять на версии собираемых приложений.

Ниже привидена команда сборки:

```ini

docker build -t edt:2025.1.1.45 --build-arg URL_INSTALL_EDT="http://localhost:8090/1c_edt_distr_offline_2025.1.1_45_linux_x86_64.tar.gz" .

```
> **Примечание:**
> Команда запускается в каталоге с файлам Dockerfile.
> Точка в конце команды обязательна!
> Если параметры --build-arg URL_INSTALL_EDT будут пропущены, пути файлов будут взяты по-умолчанию из Dockerfile-файла.

**Установка локального nginx для сборки**

Если нет доступного web-сервера, его можно запустить на локальной машине.

1. Создайте в папку, где будут храниться файлы дистрибьютивов для сборки образов (Например: <текущая папка>/install).
2. Скопируйте в папку файлы для установки в образ
3. Создайте в текущей папке конфигурационный файл nginx.conf с настройками:

```nginx

server {
   listen       80;
   listen  [::]:80;
   server_name  localhost;

   autoindex on;               # enable directory listing output
   autoindex_exact_size off;   # output file sizes rounded to kilobytes, megabytes, and gigabytes
   autoindex_localtime on;     # output local times in the directory

   location / {
       root /mnt;
    }
}

```

3. Запустите nginx c настройками конфигурационного файла из пункта 2

```bash

#!/bin/bash

docker run \
    --name my-nginx \
    -v $(pwd)/conf/nginx.conf:/etc/nginx/nginx.conf:ro \
    -v $(pwd)/conf/install:/mnt:ro \
    -p 8090:80 \
    -d nginx

```

 В результате по порту указанному при запуске (8090) у нас становиться доступным локальный web-сервер как файловый сервер через протокол http.

![alt text](../images/nginx.png)

[<- Содержание](../README.md)