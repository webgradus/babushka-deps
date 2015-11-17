babushka-deps
=============

Deps for Babushka

Наиболее полезные deps:
======================

### Настраиваем deploy.rb и unicorn.rb, выполняя из папки проекта (учитывая, что проект зависит от Capistrano ~ 3 и зависимость уже поставлена )

    babushka webgradus:prepare-deploy

### Добавляем server для nginx в sites-available с помощью (на сервере):

    babushka webgradus:server

### Добавить проект в систему бэкапирования (на сервере):

    babushka webgradus:autobackup

### Добавить проект в систему мониторинга Eye (на сервере):

    babushka webgradus:'eye-process.configured'
    
### Развернуть и сконфигурировать весь необходимый софт - Nginx, PostgreSQL, Imagemagick, Redis, RVM, Eye (на сервере):

    babushka webgradus:stack
    
### Добавить в проект поддержку Foreman, сгенерировать init скрипты и запустить (из папки проекта):

    babushka webgradus:'foreman.start'
    
### Установить KMS в режиме production (на сервере):

    babushka webgradus:'kms running'
