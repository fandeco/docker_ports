# Проброс портов в nginx 
Задача этого скрипт отслеживать изменения в докере и записывать контенеры с портами в файл и затем подключать их в nginx

После каждого stop или start контенера происходит запись в файл

# 1 Запись портов в файл

```bash
/etc/nginx/includes/docker_ports
```

и выполняется команда чтобы применить новый порты из файла
```bash
nginx reload
```

# 2. Подключение портов в nginx

В конфигурацию nginx любого сайта добавляется следующий код

```conf

# здесь объявляем переменную $container_docker и $pma_port 
# в $pma_port запишется наш порт с контенером
map $container_docker $pma_port {
    # порты всех контенеров
    include "/etc/nginx/includes/docker_ports";
}
server {
    server_name phpmyadmin.divinare.kz;
    
    
    # записиывам порт контенера в $pma_port
    set $container_docker divinare-kz-$container_prefix-phpmyadmin-1;
    
    # Пример проксирования
    location ~ \/pma {
        rewrite ^/pma(/.*)$ $1 break;
        proxy_set_header X-Real-IP  $remote_addr;
        proxy_set_header HOST $host;
        proxy_set_header X-Forwarded-For $remote_addr;

        # сюда передает порт контенера $pma_port
        proxy_pass      http://127.0.0.1:$pma_port;
    }
}

```
