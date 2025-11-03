# ОПИСАНИЕ

Это репозиторий Git содержит исходники для сборки образа docker предназначенного для проведения тестирования конфигруаций 1С.

**Содержание**
- [Сборка образа](doc/image_buid.md)
  - [Этапы сборки](doc/image_buid.md#этапы-сборки)
  - [Использование web-сервера в качестве файловового сервера](doc/image_buid.md#использование-web-сервера-в-качестве-файловового-сервера)
- [Состав образа](doc/image_buid.md)
  - [Базовый образ](doc/image_buid.md#базовый-образ)
  - [Docker Mode](doc/docker_mode.md)
    - [Функционал](doc/docker_mode.md#функционал)
    - [Пример подключения Docker-mods](doc/docker_mode.md#пример-подключения-docker-mods)
  - [EDT](doc/image_buid.md#edt)
  - [Платформа 1С](doc/image_buid.md#платформа-1с)
  - [CLI-LIB](doc/cli_lib.md)
    - [cli-common](doc/cli_lib.md#cli-common)
    - [cli-edt](doc/cli_lib.md#cli-edt)
- [Использование образа](doc/image_applying.md)
  - [Настройка образа](doc/image_applying.md#настройка-образа)
  - [Запуск  контейнера](doc/image_applying.md#запуск--контейнера)
  - [Переменные среды, сборки и тестирования](doc/image_applying.md#переменные-среды-сборки-и-тестирования)
