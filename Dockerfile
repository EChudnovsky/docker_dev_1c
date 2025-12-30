# Базовая сборка
FROM linuxserver/rdesktop:ubuntu-xfce AS rdesktop_base

# Первая строка RUN - подготовка согласия с лицензионным соглашением для установки Windows шрифтов
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections \
    && apt-get update && apt-get install -y --no-install-recommends \
    git locales p7zip xfce4-xkb-plugin \
    libfontconfig1 libfreetype6 libglib2.0-0 \ 
    libpng16-16 libx11-6 libxext6 libxrender1 libxtst6 libxml2 libxslt1.1 libwebkit2gtk-4.1-0 \
    at-spi2-core \
    ttf-mscorefonts-installer \
    && fc-cache -f -v \
    && rm -rf /var/lib/apt/lists/*

# Установка edt требуемых версий
FROM rdesktop_base AS base_1c

ARG PATH_INSTALL_EDT="http://localhost:8090/1c_edt_distr_offline_2025.1.4_15_linux_x86_64.tar.gz"
ARG PATH_INSTALL_1C="http://localhost:8090/server64_8_3_24_1819.zip"

ADD --link $PATH_INSTALL_EDT /tmp/install/edt/1cedt.tar.gz
ADD --link $PATH_INSTALL_1C /tmp/install/1с/1c.zip

RUN echo "**** INSTALL EDT ****" \
    && tar -xvf "/tmp/install/edt/1cedt.tar.gz" -C "/tmp/install/edt" \
    && chmod +x /tmp/install/edt/1ce-installer-cli \
    && /tmp/install/edt/1ce-installer-cli install --ignore-hardware-checks --ignore-signature-warnings \
    && echo "**** INSTALL PLATFORM 1C ****" \
    && 7z x /tmp/install/1с/1c.zip -o/tmp/install/1с \
    && find /tmp/install/1с/ -type f -name "setup-full-8*.run" -exec sh -c '{} --mode unattended --installer-language ru --enable-components client_full,ru,server,ws' \;

FROM rdesktop_base AS dev_1c
COPY --from=base_1c  /opt/ /opt/
COPY --from=base_1c  /home/ /home/
COPY --from=base_1c  /root/ /root/
COPY root/ /

# СЛУЖЕБНЫЕ ПЕРЕМЕННЫЕ
ENV LANG=ru_RU.UTF-8 LC_ALL=ru_RU.UTF-8

# ПЕРЕМЕННЫЕ СРЕДЫ, СБОРКИ И ТЕСТИРОВАНИЯ

# Путь к внешнему ресурсу.
# Если переменная содержит адрес, то при запуске контейнера, будет выполняться 
# скачивание файла и если это архив его распаковка в директорию ${PROJECT_BULD_DIR}/inbox
# Допустимые форматы *.cf, *.cfu, *.dt.
# Поддерживаемые архивы: .zip, .tar, .tar.gz, .tar.bz2, .tar.xz, .rar, .7z
# Пример: http://localhost:8090/data_test.zip
ENV RESOURCE_PATH=

# Домашний каталог JAVA
ENV JAVA_HOME=""

# Путь к библиотеке общих скриптов
ENV CLI_LIB_PATH="/usr/local/sbin"

# ПЕРЕМЕННЫЕ GITLAB ДЛЯ РАБОТЫ С ПРОЕКТОМ

# Имя проекта
ENV CI_PROJECT_NAME=""
# Директория проекта
ENV CI_PROJECT_DIR=""

# ОБЩИЕ ПЕРЕМЕННЫЕ

# Директория сборки
ENV PROJECT_BULD_DIR=""
# 
# Директория логирования
ENV LOG_PATH_DIR=""
# Имя основного файла логирования сборки CI\CD
ENV LOG_PATH_FILE=""
# Уровень логирования в скриптах
# Доступные значения: DEBUG|INFO|WARN|ERROR 
ENV LOG_LEVEL="INFO"
# Вывод в консоль, доступные значения true|false
ENV LOG_TO_CONSOLE="true"
# Вывод в файл, доступные значения true|false
ENV LOG_TO_FILE="true"
# Цветной вывод в консоль (если поддерживается), доступные значения true|false
ENV LOG_COLORIZED="true"

# ПЕРЕМЕННЫЕ ДЛЯ РАБОТЫ С EDT
# Домашний каталог EDT
ENV EDT_HOME=""
# Домашний каталог RING
ENV RING_HOME=""
# Лимит памяти выделяемый для запуска EDT
ENV EDT_MEMORY_LIMIT=6124m
# Один или несколько аргументов JVM (например, -Xmx, -D и т. д.).
# Если заданы, тогда являются приоритетными перед файлоv ini
# Например, при импорте проекта можно увеличить размер кучи до 8 Гб (-Xmx8g) 
ENV EDT_VMARGS=""
# Максимальное время в секундах для выполнения операций edt
ENV EDT_MAXTIMEOUT=""
# Путь к каталогу проекта edt
ENV EDT_PATH_PROJECT=""
# Путь к каталогу workspace edt
ENV EDT_PATH_WORKSPACE=""

# ПЕРЕМЕННЫЕ ДЛЯ РАБОТЫ С 1C
# Домашний каталог 1С
ENV _1C_HOME=""
# Версия используемой платформы
ENV _1C_VERSION=""
ENV _1C_VERSION_FULL=""

# Путь к базе
ENV _1C_IBSRV_CONF=""
# Путь к каталогу данных автомного сервера
ENV _1C_IBSRV_DATA=""
ENV _1C_IBSRV_PORT=8314
ENV _1C_IBSRV_PORT_DEBUG=1550
ENV _1C_IBSRV_PORT_HTTP=80

# Подключение к базе
ENV _1C_DB_PATH=""
ENV _1C_DB_NAME="db_test"
# Пользователь БД
ENV _1C_DB_USER=""
# Пароль пользователя БД
ENV _1C_DB_PWD=""

# Путь к .файлу для загрзуки в БД, возможные типы файлов: *.сf, *.cfu, *.dt
ENV _1C_DB_FILE_FOR_LOAD=""
ENV _1C_DB_PATH_CF_SAVE=""

# Настройка портов
# Автономный сервер
EXPOSE $_1C_IBSRV_PORT
EXPOSE $_1C_IBSRV_PORT_DEBUG
# Публикация БД
EXPOSE $_1C_IBSRV_PORT_HTTP

# RDP
EXPOSE 3389