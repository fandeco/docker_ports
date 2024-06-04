# Добавление демона в CentOS 7

# Создаем файл для нашего сервиса

```
sudo touch /etc/systemd/system/docker_trigger_python.service
```

# Открываем файл для редактирования

```
sudo nano /etc/systemd/system/docker_trigger_python.service
```

# Добавляем следующий код в файл

```
[Unit]
Description=Docker Trigger Python Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /root/docker_trigger_python/docker_ports.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

# Сохраняем и закрываем файл

# Обновляем список сервисов

```shell
sudo systemctl daemon-reload
```

# Включаем наш сервис

```shell
sudo systemctl enable docker_trigger_python.service
```

```shell
sudo systemctl start docker_trigger_python.service
```
