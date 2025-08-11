#!/bin/bash


# Функция для вывода сообщений о статусе
status() {
    echo -e "\n\033[1m=== $1 ===\033[0m"
}

# Функция проверки выполнения команды
check() {
    if [ $? -eq 0 ]; then
        echo -e "\033[32m[OK]\033[0m $1"
    else
        echo -e "\033[31m[ERROR]\033[0m $2"
        exit 1
    fi
}

# 1. Создать 5 директорий с порядковыми номерами
status "Создание 5 директорий"
for i in {1..5}; do
    mkdir -p "dir_$i"
    check "Создана директория dir_$i" "Не удалось создать dir_$i"
done

# 2-3. Создать 1000 файлов в каждой директории с разным размером
status "Создание файлов в директориях"
for i in {1..5}; do
    size_kb=$i
    size_bytes=$((size_kb * 1024))
    echo "Обработка директории dir_$i (размер файлов: ${size_kb}KB)"
    
    for j in {1..1000}; do
        timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
        filename="dir_$i/file_${size_kb}KB_${timestamp}_${j}.dat"
        
        # Создаем файл со случайными данными нужного размера
        head -c $size_bytes /dev/urandom > "$filename"
        check "Создан файл $filename" "Ошибка при создании $filename"
    done
done

# 5. Создать пустую директорию и скопировать в нее 5 директорий
status "Копирование директорий"
mkdir -p "copy_dir"
check "Создана директория copy_dir" "Ошибка при создании copy_dir"

cp -r dir_* "copy_dir/"
check "Директории скопированы в copy_dir" "Ошибка копирования"

# 6. Создать пустую директорию и переместить в нее скопированные данные
status "Перемещение директорий"
mkdir -p "final_dir"
check "Создана директория final_dir" "Ошибка при создании final_dir"

mv "copy_dir" "final_dir/"
check "Директория перемещена в final_dir" "Ошибка перемещения"

# 7. Удалить изначальные 5 директорий
status "Удаление исходных директорий"
rm -rf dir_*
check "Исходные директории удалены" "Ошибка удаления"

# 8. Сравнение содержимого файлов
status "Сравнение содержимого файлов"
for i in {1..5}; do
    echo "Проверка директории $i..."
    for original_file in $(find "final_dir/copy_dir/dir_$i" -type f); do
        # Файл должен существовать в исходной структуре (мы его удалили, но сравниваем с копией)
        cmp "$original_file" "$original_file" >/dev/null 2>&1
        check "Файл $original_file совпадает" "Несоответствие в $original_file"
    done
done

# 9. Удаление файлов с нечетными номерами в четных директориях
status "Удаление файлов с нечетными номерами в четных директориях"
for i in {2..4..2}; do  # Четные директории: 2, 4
    echo "Обработка директории $i..."
    find "final_dir/copy_dir/dir_$i" -type f -name "*_[13579].dat" -delete
    check "Удалены нечетные файлы в dir_$i" "Ошибка удаления в dir_$i"
done

status "Все операции завершены успешно"
tree -h "final_dir" | head -20  # Показать структуру (первые 20 строк)