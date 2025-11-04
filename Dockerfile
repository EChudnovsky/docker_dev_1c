# Базовая сборка
FROM linuxserver/rdesktop:ubuntu-xfce AS rdesktop_base

RUN apt-get update && apt-get install -y --no-install-recommends \
    git locales p7zip xfce4-xkb-plugin \
    libfontconfig1 libfreetype6 libglib2.0-0 \ 
    libpng16-16 libx11-6 libxext6 libxrender1 libxtst6 libxml2 libxslt1.1 libwebkit2gtk-4.1-0 \
    && rm -rf /var/lib/apt/lists/*

# Установка edt и  1С требуемых версий
FROM rdesktop_base AS edt-java

ARG PATH_INSTALL_EDT="http://localhost:8090/1c_edt_distr_offline_2025.1.4_15_linux_x86_64.tar.gz"
ADD --link $PATH_INSTALL_EDT /tmp/install/edt/1cedt.tar.gz

RUN echo "**** INSTALL EDT ****" \
    && tar -xvf "/tmp/install/edt/1cedt.tar.gz" -C "/tmp/install/edt" \
    && chmod +x /tmp/install/edt/1ce-installer-cli \
    && /tmp/install/edt/1ce-installer-cli install --ignore-hardware-checks --ignore-signature-warnings \
    && rm -rf /tmp/install

    # Установка edt и  1С требуемых версий
FROM rdesktop_base AS platform1c

ARG PATH_INSTALL_1C="http://localhost:8090/server64_8_3_24_1819.zip"
ADD --link $PATH_INSTALL_1C /tmp/install/1с/1c.zip

RUN echo "**** INSTALL PLATFORM 1C ****" \
    && 7z x /tmp/install/1с/1c.zip -o/tmp/install/1с \
    && find /tmp/install/1с/ -type f -name "setup-full-8*.run" -exec sh -c '{} --mode unattended --installer-language ru --enable-components client_full,ru,server,ws' \; \
    && rm -rf /tmp/install
    
FROM rdesktop_base AS dev_1c
COPY --from=edt-java  /opt/ /opt/
COPY --from=platform1c  /opt/ /opt/
COPY --from=platform1c  /home/ /home/
COPY root/ /

# СЛУЖЕБНЫЕ ПЕРЕМЕННЫЕ
ENV LANG=ru_RU.UTF-8 LC_ALL=ru_RU.UTF-8

# ПЕРЕМЕННЫЕ СРЕДЫ, СБОРКИ И ТЕСТИРОВАНИЯ

# Домашний каталог JAVA
ENV JAVA_HOME=
# Путь к библиотеке общих скриптов
ENV CLI_LIB_PATH=/usr/local/bin/lib

# ПЕРЕМЕННЫЕ GITLAB ДЛЯ РАБОТЫ С ПРОЕКТОМ
# Имя проекта
ENV CI_PROJECT_NAME="test_project"
# Путь к каталогу проекта edt
ENV CI_PROJECT_DIR=/config/1c_edt

# ОБЩИЕ ПЕРЕМЕННЫЕ
# Путь к каталогу сборки проекта edt
ENV PROJECT_BULD_DIR=${CI_PROJECT_DIR}/buld
# Путь к каталогу логирования проекта edt
ENV PROJECT_LOG_DIR=${PROJECT_BULD_DIR}/log

# ПЕРЕМЕННЫЕ ДЛЯ РАБОТЫ С EDT
# Домашний каталог EDT
ENV EDT_HOME=
# Домашний каталог RING
ENV RING_HOME=
# Лимит памяти выделяемый для запуска EDT
ENV EDT_MEMORY_LIMIT=6124m
# Один или несколько аргументов JVM (например, -Xmx, -D и т. д.).
# Если заданы, тогда являются приоритетными перед файлоv ini
# Например, при импорте проекта можно увеличить размер кучи до 8 Гб (-Xmx8g) 
ENV EDT_VMARGS=
# Максимальное время в секундах для выполнения операций edt
ENV EDT_MAXTIMEOUT=
# Путь к каталогу проекта edt
ENV EDT_PATH_PROJECT=${CI_PROJECT_DIR}/src
# Путь к каталогу workspace edt
ENV EDT_PATH_WORKSPACE=${PROJECT_BULD_DIR}/workspace
# Путь к каталогу скриптов для edt 1cedtcli
ENV EDTCLI_SCRIPT_PATH=/1c_edt/cli-scripts/

# ПЕРЕМЕННЫЕ ДЛЯ РАБОТЫ С 1C
# Домашний каталог 1С
ENV _1C_HOME=
# Версия используемой платформы
ENV _1C_VERSION=
ENV _1C_VERSION_FULL=
# Имя базы
ENV _1C_DB_NAME="db_test"
# Путь к базе
ENV _1C_DB_PATH=${PROJECT_BULD_DIR}/infobase
# Путь к .cf-файлу, на основе которого будет создана база или выгружен из БД
ENV _1C_DB_PATH_CF=${PROJECT_BULD_DIR}/${CI_PROJECT_NAME}.cf

# Настройка портов
EXPOSE 80
# RDP
EXPOSE 3389