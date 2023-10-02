#!/bin/bash

# Чтение ключевых слов из файла .env
source ../.env
KEYWORDS="$KEYWORDS"

if [ -z "$KEYWORDS" ]; then
    echo "Переменная KEYWORDS не определена"
    exit 1
else
    echo "Переменная KEYWORDS: $KEYWORDS"
fi

# Получение списка запущенных контейнеров
CONTAINERS=$(docker ps -a --format "{{.Names}}")

# Разделение ключевых слов по запятым
IFS=',' read -ra KEYWORDS_ARRAY <<< "$KEYWORDS"

# Перебор всех контейнеров
for container in $CONTAINERS; do
    # Проверка каждого ключевого слова
    for keyword in "${KEYWORDS_ARRAY[@]}"; do
        # Проверка наличия ключевого слова в имени контейнера
        if [[ "$container" == *"$keyword"* ]]; then
            # Получение времени запуска контейнера
            START_TIME=$(docker inspect -f '{{.State.StartedAt}}' "$container")
            # Преобразование времени в секунды
            START_TIME_SECONDS=$(date -d "$START_TIME" +%s)
            # Получение текущего времени в секундах
            CURRENT_TIME_SECONDS=$(date +%s)
            # Вычисление разницы времени в днях
            TIME_DIFF=$(( (CURRENT_TIME_SECONDS - START_TIME_SECONDS) / (60 * 60 * 24) ))
            # Проверка, превышает ли время запуска 4 дня
            if [ "$TIME_DIFF" -gt 4 ]; then
                # Удаление контейнера
                docker rm "$container" -f
                echo "Удаляем контейнер $container"
            fi
        fi
    done
done
